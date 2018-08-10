function testSpeed(N, path)

DEFAULT_N = 1e3;
DEFAULT_PATH = 'logger_speed_test.log';
switch nargin
   case 0
      N = DEFAULT_N;
      path = DEFAULT_PATH;
   case 1
      path = DEFAULT_PATH;
   case 2
end

L = utils.Logger('Logger.testSpeed', path);

%%% TEST 1
L.windowLevel = L.TRACE;
L.level = L.OFF;
tstart = tic;
for i=1:N
   L.trace('test');
end
t1 = toc(tstart);

%%% TEST 2
L.windowLevel = L.OFF;
L.level = L.OFF;
tstart = tic;
for i=1:N
   L.trace('test');
end
t2 = toc(tstart);

%%% TEST 3
L.windowLevel = L.OFF;
L.level = L.TRACE;
tstart = tic;
for i=1:N
   L.trace('test');
end
t3 = toc(tstart);

%%% TEST 4
L.windowLevel = L.TRACE;
L.level = L.TRACE;
tstart = tic;
for i=1:N
   L.trace('test');
end
t4 = toc(tstart);

fprintf ('\n');
fprintf ('%.0E logs - completely off:     %7.3f | %.2E avg\n', ...
   N, t2, t2 / N);
fprintf ('------------ only to window:     %7.3f | %.2E avg\n', ...
   t1, t1 / N);
fprintf ('------------ only to file:       %7.3f | %.2E avg\n', ...
   t3, t3 / N);
fprintf ('------------ to window and file: %7.3f | %.2E avg\n', ...
   t4, t4 / N);
end
