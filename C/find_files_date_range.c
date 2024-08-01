#include <stdio.h>
#include <stdlib.h>
#include <dirent.h>
#include <sys/stat.h>
#include <string.h>
#include <time.h>

#define MAX_PATH 4096
#define DATE_FORMAT "%Y-%m-%d"

typedef struct {
    char path[MAX_PATH];
    time_t mtime;
} FileEntry;

time_t parse_date(const char *date_str) {
    struct tm tm = {0};
    if (strptime(date_str, DATE_FORMAT, &tm) == '\0') {
        return -1;
    }
    return mktime(&tm);
}

void insert_file(FileEntry **files, int *num_files, int *capacity, const char *path, time_t mtime) {
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
    (*files)[*num_files].mtime = mtime;
    (*num_files)++;
}

void sort_files(FileEntry files[], int num_files) {
    int i, j;
    FileEntry key;

    for (i = 1; i < num_files; i++) {
        key = files[i];
        j = i - 1;
        while (j >= 0 && files[j].mtime < key.mtime) {
            files[j + 1] = files[j];
            j--;
        }
        files[j + 1] = key;
    }
}

void find_newest_files(const char *dir_path, time_t start_date, time_t end_date, FileEntry **files, int *num_files, int *capacity) {
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
            find_newest_files(path, start_date, end_date, files, num_files, capacity);
        } else if (entry->d_type == DT_REG) {
            snprintf(path, sizeof(path), "%s/%s", dir_path, entry->d_name);
            if (stat(path, &file_stat) == -1) {
                perror("stat");
                continue;
            }
            if (file_stat.st_mtime >= start_date && file_stat.st_mtime <= end_date) {
                insert_file(files, num_files, capacity, path, file_stat.st_mtime);
            }
        }
    }
    closedir(dir);
}

int main(int argc, char *argv[]) {
    time_t start_date, end_date;
    FileEntry *files = NULL;
    int num_files = 0;
    int capacity = 10;  // Initial capacity for files

    if (argc != 4) {
        fprintf(stderr, "Usage: %s <directory> <start_date> <end_date>\n", argv[0]);
        return 1;
    }

    start_date = parse_date(argv[2]);
    end_date = parse_date(argv[3]);
    if (start_date == -1 || end_date == -1) {
        fprintf(stderr, "Invalid date format. Use YYYY-MM-DD.\n");
        return 1;
    }

    files = (FileEntry *)malloc(capacity * sizeof(FileEntry));
    if (files == NULL) {
        perror("malloc");
        return 1;
    }

    find_newest_files(argv[1], start_date, end_date, &files, &num_files, &capacity);
    sort_files(files, num_files);

    printf("Newest files between %s and %s:\n", argv[2], argv[3]);

    {
        int i;
        for (i = 0; i < num_files; i++) {
            printf("%d. %s (last modified: %s)\n", i + 1, files[i].path, ctime(&files[i].mtime));
        }
    }

    free(files);
    return 0;
}
