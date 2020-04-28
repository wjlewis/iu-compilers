#include <inttypes.h>
#include <stdio.h>
#include "runtime.h"

int64_t read_int() {
    int64_t i;
    scanf("%" SCNd64, &i);
    return i;
}
