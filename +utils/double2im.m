function I = double2im(X, outputClass)
I = cast(X * double(intmax(outputClass)), outputClass);
