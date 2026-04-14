#include <stdio.h>
#include <dlfcn.h>
#include <string.h>

typedef int (*fptr)(int, int);

int main() {
    char s[7];
    int p, q;

    while (scanf("%s %d %d", s, &p, &q) == 3) {
        char lib[20] = "./lib";
        strcat(lib, s);
        strcat(lib, ".so");

        void *handle = dlopen(lib, RTLD_LAZY);
        if (!handle) continue; // forerror 

        fptr fun = (fptr)dlsym(handle, s);
        if (fun) {
            printf("%d\n", fun(p, q));
        }

        dlclose(handle);
    }

    return 0;
}