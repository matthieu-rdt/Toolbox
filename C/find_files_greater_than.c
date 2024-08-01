#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>
#include <string.h>
#include <time.h>
#include <stdint.h>  // For intmax_t

#define MAX_PATH 4096

typedef struct {
    char path[MAX_PATH];
    off_t size;
} FileEntry;

off_t parse_size(const char *size_str) {
    char suffix;
    intmax_t size;
    if (sscanf(size_str, "%jd%c", &size, &suffix) < 1) {
        return -1;
    }
    switch (suffix) {
        case 'K': case 'k': size *= 1024; break;
        case 'M': case 'm': size *= 1024 * 1024; break;
        case 'G': case 'g': size *= 1024 * 1024 * 1024; break;
        default: break;
    }
    return (off_t)size;
}

void human_readable_size(off_t size, char *output, size_t output_size) {
    const char *units[] = {"B", "KB", "MB", "GB", "TB"};
    int unit_index = 0;
    double display_size = (double)size;

    while (display_size >= 1024 && unit_index < 4) {
        display_size /= 1024;
        unit_index++;
    }
    snprintf(output, output_size, "%.2f %s", display_size, units[unit_index]);
}

void insert_file(FileEntry **files, int *num_files, int *capacity, const char *path, off_t size) {
    if (*num_files >= *capacity) {
        *capacity *= 2;
        *files = (FileEntry *)realloc(*files, *capacity * sizeof(FileEntry));
        if (*files == NULL) {
            perror("realloc");
            exit(1);
        }
    }
    strncpy((*files)[*num_files].path, path, MAX_PATH - 1);
    (*files)[*num_files].path[MAX_PATH - 1] = '\0';
    (*files)[*num_files].size = size;
    (*num_files)++;
}

void sort_files(FileEntry files[], int num_files) {
    int i, j;
    FileEntry key;

    for (i = 1; i < num_files; i++) {
        key = files[i];
        j = i - 1;
        while (j >= 0 && files[j].size < key.size) {
            files[j + 1] = files[j];
            j--;
        }
        files[j + 1] = key;
    }
}

void find_biggest_files(const char *dir_path, off_t min_size, FileEntry **files, int *num_files, int *capacity) {
    struct dirent *entry;
    struct stat file_stat;
    char path[MAX_PATH];
    DIR *dir;

    dir = opendir(dir_path);
    if (!dir) {
        perror("opendir");
        return;
    }

    while ((entry = readdir(dir)) != NULL) {
        if (entry->d_type == DT_DIR) {
            if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0) {
                continue;
            }
            snprintf(path, sizeof(path), "%s/%s", dir_path, entry->d_name);
            find_biggest_files(path, min_size, files, num_files, capacity);
        } else if (entry->d_type == DT_REG) {
            snprintf(path, sizeof(path), "%s/%s", dir_path, entry->d_name);
            if (stat(path, &file_stat) == -1) {
                perror("stat");
                continue;
            }
            if (file_stat.st_size >= min_size) {
                insert_file(files, num_files, capacity, path, file_stat.st_size);
            }
        }
    }
    closedir(dir);
}

int main(int argc, char *argv[]) {
    off_t min_size;
    FileEntry *files = NULL;
    int num_files = 0;
    int capacity = 10;  // Initial capacity for files

    if (argc != 3) {
        fprintf(stderr, "Usage: %s <directory> <min_size>\n", argv[0]);
        return 1;
    }

    min_size = parse_size(argv[2]);
    if (min_size == -1) {
        fprintf(stderr, "Invalid minimum size: %s\n", argv[2]);
        return 1;
    }

    files = (FileEntry *)malloc(capacity * sizeof(FileEntry));
    if (files == NULL) {
        perror("malloc");
        return 1;
    }

    find_biggest_files(argv[1], min_size, &files, &num_files, &capacity);
    sort_files(files, num_files);

    printf("Biggest files:\n");

    {
        int i;
        char human_readable_size_str[20];
        for (i = 0; i < num_files; i++) {
            human_readable_size(files[i].size, human_readable_size_str, sizeof(human_readable_size_str));
            printf("%d. %s (size: %s)\n", i + 1, files[i].path, human_readable_size_str);
        }
    }

    free(files);
    return 0;
}
