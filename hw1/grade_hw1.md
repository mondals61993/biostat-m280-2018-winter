*Sangeeta Mondal*

### Overall Grade: 84/100

### Quality of report: 9/10

-   Is the homework submitted (git tag time) before deadline?

    Yes. `Feb 1, 2018, 2:50 PM PST`.

-   Is the final report in a human readable format html? (-1 pt)

    Yes, but please create a single `hw1.Rmd` that includes answers to all the questions.

-   Is the report prepared as a dynamic document (R markdown) for better reproducibility?

    Yes. `Rmd`.

-   Is the report clear (whole sentences, typos, grammar)? Do readers have a clear idea what's going on and how are results produced by just reading the report?

    Yes.

### Correctness and efficiency of solution: 42/50

-   Q1 (10/10)

-   Q2 (19/20)

    \#2. The following implementation (from Dr. Zhou's solution sketch) is fast as it traverses `bim` file only once. The `uniq` command in Linux is useful for counting but takes longer.

    ``` bash
    time awk '
    {chrno[$1]++;} 
    END{ for (c in chrno) print "chr.", c, "has", chrno[c], "SNPs"}'                                   
    /home/m280-data/hw1/merge-geno.bim
    ```

    \#4. (-1 pt) Need to write the folloiwng two lines to Mendenl SNP definition file.

            2.40 = FILE FORMAT VERSION NUMBER.
        8348674  = NUMBER OF SNPS LISTED HERE.

-   Q3 (13/20)

    \#1. (-7 pts)
    -   `runSim.R`:
        -   Use `rcauchy` for the Cauchy distribution.
        -   You need to set the seed `set.seed(280)` before generating random numbers.
        -   Your current implementation of MSE is wrong. You need to sum elements in the first column to get `MSE1` and sum elements in the second column to get `MSE2`.

        ``` r
        # your current code 
        MSE1<-(sum(est[1]^2))/50 #mean primes
        MSE2<-(sum(est[2]^2))/50 #classical
        # what it should be 
        MSE1 <- (sum(est[, 1]^2)) / rep # mean primes
        MSE2 <- (sum(est[, 2]^2)) / rep # classical
        ```

### Usage of Git: 10/10

-   Are branches (`master` and `develop`) correctly set up? Is the hw submission put into the `master` branch?

    Yes.

-   Are there enough commits? Are commit messages clear?

    Yes.

-   Are the folders (`hw1`, `hw2`, ...) created correctly?

    Yes.

-   Do not put a lot auxillary files into version control.

    Yes.

### Reproducibility: 7/10

-   Are the materials (files and instructions) submitted to the `master` branch sufficient for reproducing all the results? (-3 pts)

    -   In your `collection.Rmd`, the path `/home/mondals/biostat-m280-2018-winter/` is unque to your account. Make sure your collaborators can easily run your code. You may try something like this instead:

        ``` r
        folder <- "./"
        file_list <- list.files(path = folder, pattern = "n\\d\\d\\d.*.txt")
        ```

    -   `autoSim.R` must be run prior to any code chunk in `collection.Rmd`. Add the following bash code chunk in the beginning.


            ```bash
            Rscript autoSim.R
            ```

           
-   If necessary, are there clear instructions, either in report or in a separate file, how to reproduce the results?

    Yes.

### R code style: 16/20

-   [Rule 3](https://google.github.io/styleguide/Rguide.xml#linelength): Never place more than 80 characters on a line.

-   [Rule 4](https://google.github.io/styleguide/Rguide.xml#indentation): 2 spaces for indenting.

-   [Rule 5](https://google.github.io/styleguide/Rguide.xml#spacing): Place spaces around all binary operators (`=`, `+`, `-`, `<-`, etc.). Exception: Spaces around `=`'s are optional when passing parameters in a function call. (-2 pts)

    -   `runSim.R`: lines 32-33, 43-45, 48-50, 54-55
    -   `autoSim.R`: lines 2-3
    -   `collection.Rmd`
        -   Need spaces around `/`, `<-`

-   [Rule 5](https://google.github.io/styleguide/Rguide.xml#spacing): Do not place a space before a comma, but always place one after a comma. (-2 pts)

    -   `runSim.R`: lines 33, 39-40, 44-45, 49-50
    -   `collection.Rmd`: last code chunk

-   [Rule 5](https://google.github.io/styleguide/Rguide.xml#spacing): Place a space before left parenthesis, except in a function call. Do not place spaces around code in parentheses or square brackets. Exception: Always place a space after a comma.
