*Sangeeta Mondal*

### Overall Grade: 94/100

### Quality of report: 10/10

-   Is the homework submitted (git tag time) before deadline?

    Yes. `Mar 2, 2018, 7:17 PM PST`.

-   Is the final report in a human readable format html?

    Yes, `html`.

-   Is the report prepared as a dynamic document (R markdown) for better reproducibility?

    Yes. `Rmd`.

-   Is the report clear (whole sentences, typos, grammar)? Do readers have a clear idea what's going on and how are results produced by just reading the report?

    Yes.

### Correctness and efficiency of solution: 48/50

-   Q1 (25/25)

-   Q2 (23/25)
    -   Answer the questions using **plots** and summary statistics.

### Usage of Git: 10/10

-   Are branches (`master` and `develop`) correctly set up? Is the hw submission put into the `master` branch?

    Yes.

-   Are there enough commits? Are commit messages clear?

    Yes.

-   Are the folders (`hw1`, `hw2`, ...) created correctly?

    Yes.

-   Do not put a lot auxillary files into version control.

    Yes.

### Reproducibility: 9/10

-   Are the materials (files and instructions) submitted to the `master` branch sufficient for reproducing all the results? (-1 pt)

    I see your comments on running RDS file locally, but you could have done

    ``` r
    saveRDS(payroll_p, './question1/payroll_p.rds', compress = TRUE)
    ```

    instead of using the path unique to your account on the server:

    ``` r
    saveRDS(payroll_p, '/home/mondals/biostat-m280-2018-winter/hw3/question1/payroll_p.rds',
         compress = TRUE)
    ```

-   If necessary, are there clear instructions, either in report or in a separate file, how to reproduce the results?

    Yes.

### R code style: 17/20

-   [Rule 3](https://google.github.io/styleguide/Rguide.xml#linelength): Never place more than 80 characters on a line. (-2 pts)

    -   Some violations:
        -   `app.R`: lines 55-68, etc.

-   [Rule 4](https://google.github.io/styleguide/Rguide.xml#indentation): 2 spaces for indenting.

-   [Rule 5](https://google.github.io/styleguide/Rguide.xml#spacing): Place spaces around all binary operators (`=`, `+`, `-`, `<-`, etc.). Exception: Spaces around `=`'s are optional when passing parameters in a function call. (-1 pt)

    -   Need spaces around `%>%`.

-   [Rule 5](https://google.github.io/styleguide/Rguide.xml#spacing): Do not place a space before a comma, but always place one after a comma.

-   [Rule 5](https://google.github.io/styleguide/Rguide.xml#spacing): Place a space before left parenthesis, except in a function call. Do not place spaces around code in parentheses or square brackets. Exception: Always place a space after a comma.
