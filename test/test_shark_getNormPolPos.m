function test_shark_getNormPolPos(shark)

% Shark in front
angle = pi/2;
tests = {[1,1],[1,-1;1,1;-1,1],[0,0.5,1]; ...
         [1,-1],[-1,-1;1,-1;1,1],[0,0.5,1]; ...
         [-1,-1],[-1,1;-1,-1;1,-1],[0,0.5,1]; ...
         [-1,1],[1,1;-1,1;-1,-1],[0,0.5,1]};

for j=1:4
  shark.direction = tests{j,1};
  for k=1:3
    [~, res] = shark.getNormPolPos(angle,tests{j,2}(k,:), 10);
    res = round(res,5);
    assert(res == tests{j,3}(k), ...
      'Result was %.4f, should have been %.1f for direction [%i %i] and pos [%i %i]', ...
      res, tests{j,3}(k), tests{j,1}(1), tests{j,1}(2),tests{j,2}(k,1),tests{j,2}(k,2));
  end
end

% Shark in back
angle = -pi/2;
tests = {[1,1],[1,-1;-1,-1;-1,1],[1,0.5,0]; ...
         [1,-1],[-1,-1;-1,1;1,1],[1,0.5,0]; ...
         [-1,-1],[-1,1;1,1;1,-1],[1,0.5,0]; ...
         [-1,1],[1,1;1,-1;-1,-1],[1,0.5,0]};

for j=1:4
  shark.direction = tests{j,1};
  for k=1:3
    [~, res] = shark.getNormPolPos(angle,tests{j,2}(k,:), 10);
    res = round(res,5);
    assert(res == tests{j,3}(k), ...
      'Result was %.4f, should have been %.1f for direction [%i %i] and pos [%i %i]', ...
      res, tests{j,3}(k), tests{j,1}(1), tests{j,1}(2),tests{j,2}(k,1),tests{j,2}(k,2));
  end
end

disp('Test Passed!')
