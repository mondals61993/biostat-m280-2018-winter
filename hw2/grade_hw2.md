*Sangeeta Mondal*

### Overall Grade: 94/100

### Quality of report: 10/10

-   Is the homework submitted (git tag time) before deadline?

    Yes. `Feb 16, 2018, 8:05 PM PST`.

-   Is the final report in a human readable format html?

    Yes, `html`.

-   Is the report prepared as a dynamic document (R markdown) for better reproducibility?

    Yes. `Rmd`.

-   Is the report clear (whole sentences, typos, grammar)? Do readers have a clear idea what's going on and how are results produced by just reading the report?

    Yes. Good job!

### Correctness and efficiency of solution: 50/50

-   Q1 (25/25)
    -   7.3.4, 7.4.1, 7.5.1.1, 7.5.2.1, and 7.5.3.1.
-   Q3 (25/25)

### Usage of Git: 8/10

-   Are branches (`master` and `develop`) correctly set up? Is the hw submission put into the `master` branch?

    Yes.

-   Are there enough commits? Are commit messages clear? (-2 pts)

    7 commits in develop for hw2. All commits except for one are on 2/16. **Make sure** to start version control from the very beginning of a project. Make as many commits as possible during the process.

-   Are the folders (`hw1`, `hw2`, ...) created correctly?

    Yes.

-   Do not put a lot auxillary files into version control.

    Yes.

### Reproducibility: 8/10

-   Are the materials (files and instructions) submitted to the `master` branch sufficient for reproducing all the results? (-2 pts)

    -   The paths `/home/mondals/biostat-m280-2018-winter/mpf.csv` and `/home/mondals/biostat-m280-2018-winter/hw2/mendel_form.csv` are specific to your account on the server. Make sure your collaborators can easily run your code. You may try something like this instead:

    ``` r
    write_csv(msnp, 'mendel_form.csv', col_names = FALSE)
    write_csv(mpf, 'mpf.csv', col_names = FALSE)
    ```

-   If necessary, are there clear instructions, either in report or in a separate file, how to reproduce the results?

    Yes.

### R code style: 18/20

-   [Rule 3](https://google.github.io/styleguide/Rguide.xml#linelength): Never place more than 80 characters on a line.

-   [Rule 4](https://google.github.io/styleguide/Rguide.xml#indentation): 2 spaces for indenting.

-   [Rule 5](https://google.github.io/styleguide/Rguide.xml#spacing): Place spaces around all binary operators (`=`, `+`, `-`, `<-`, etc.). Exception: Spaces around `=`'s are optional when passing parameters in a function call. (-2 pts)

    -   Some violations: code chunks for Q3 \#1, 2, 3, and 4.
        -   Need spaces around `<-`.
-   [Rule 5](https://google.github.io/styleguide/Rguide.xml#spacing): Do not place a space before a comma, but always place one after a comma.

-   [Rule 5](https://google.github.io/styleguide/Rguide.xml#spacing): Place a space before left parenthesis, except in a function call. Do not place spaces around code in parentheses or square brackets. Exception: Always place a space after a comma.
