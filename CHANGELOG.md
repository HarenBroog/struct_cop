# Changelog

## v0.2.0

### Enhancements

- `StructCop.Changeset.cast_all/2` accepts also `%Ecto.Changeset{}` as a first argument. In this case, struct module is derrived from `:data` field.
- `StructCop.Changeset.cast_all/2` fallbacks to `cast_all/2` when casting embeds and embedded module does not implement `StructCop` behaviour nor `changeset/2` function.

---

## v0.1.0 - initial release
