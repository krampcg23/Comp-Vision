function outStructArray = SortArrayofStruct( structArray, fieldName )
    if ( ~isempty(structArray) &&  length (structArray) > 0)
      [~,I] = sort(arrayfun (@(x) x.(fieldName), structArray)) ;
      outStructArray = structArray(I) ;        
    else 
        disp ('Array of struct is empty');
    end      
end