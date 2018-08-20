function I = double2im(X, outputClass)
I = cast(X * cast(intmax(outputClass), 'like', X), outputClass);
