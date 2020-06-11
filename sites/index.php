<html>
    <head>
        <title>sites</title>
        <link rel="icon" type="image/png" href="favicon.png">
        <style>
            html{
                font-family: sans-serif;
                font-size: 18px;
                padding: 50px;
            }
            a.website {
                display: inline-block;
                text-decoration: none;
                margin-bottom: 1em;
            }
            a:hover {
                text-decoration: underline;
            }
        </style>
    </head>
    <body>
        <?php
            # Render a list of links to sub-folders
            $dirs = array_filter(glob('*'), 'is_dir');
            foreach ($dirs as $dir) {
                echo "<a class=\"website\" href='$dir'>$dir</a> <br>";
            }
        ?>
    </body>
</html>