capitalizeByWord(data) {
  if (data.trim().isEmpty) {
    return '';
  }
  return data
      .split(' ')
      .map((element) =>
          "${element[0].toUpperCase()}${element.substring(1).toLowerCase()}")
      .join(" ");
}
