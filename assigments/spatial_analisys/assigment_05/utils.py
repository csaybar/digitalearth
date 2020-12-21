from rio_cogeo.cogeo import cog_translate, cog_validate
from rio_cogeo.profiles import cog_profiles
import pystac
import re

def convert_to_cog_single(filename: str, validate: bool = True) -> str:
    """Convert a GeoTIFF to COG

    Args:
        filename (str): filename.
        output_profile (dict): Dictionary with COG arguments
        validate (bool, optional): Validate COG before to print the filename. Defaults to True.
    Raises:
        Exception: Filename needs to be a GeoTIFF file!

    Returns:
        str: The filename with the image converted to COG.
    """
    tiff_inspector = re.compile('\\.tif$|\\.tiff$')
    output_profile = cog_profiles["lzw"]
    if not tiff_inspector.search(filename):
        raise Exception("Filename needs to be a GeoTIFF file.")        
    cog_translate(filename, filename, output_profile, quiet=True)
    if validate:
        cog_validate(filename)
    return filename
