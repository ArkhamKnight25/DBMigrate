package dbutil_test

import (
	"testing"

	"github.com/ArkhamKnight25/dbmigrate/pkg/dbtest"
	"github.com/ArkhamKnight25/dbmigrate/pkg/dbutil"

	"github.com/stretchr/testify/require"
)

func TestDatabaseName(t *testing.T) {
	t.Run("valid", func(t *testing.T) {
		u := dbtest.MustParseURL(t, "foo://host/dbname?query")
		name := dbutil.DatabaseName(u)
		require.Equal(t, "dbname", name)
	})

	t.Run("empty", func(t *testing.T) {
		u := dbtest.MustParseURL(t, "foo://host")
		name := dbutil.DatabaseName(u)
		require.Equal(t, "", name)
	})
}

func TestTrimLeadingSQLComments(t *testing.T) {
	in := "--\n" +
		"-- foo\n\n" +
		"-- bar\n\n" +
		"real stuff\n" +
		"-- end\n"
	out, err := dbutil.TrimLeadingSQLComments([]byte(in))
	require.NoError(t, err)
	require.Equal(t, "real stuff\n-- end\n", string(out))
}

func TestStripPsqlMetaCommands(t *testing.T) {
	t.Run("strips restrict and unrestrict", func(t *testing.T) {
		in := "\\restrict dbmigrate\n" +
			"-- comment\n" +
			"SET statement_timeout = 0;\n" +
			"CREATE TABLE users (id int);\n" +
			"\\unrestrict dbmigrate\n"
		out, err := dbutil.StripPsqlMetaCommands([]byte(in))
		require.NoError(t, err)
		expected := "-- comment\n" +
			"SET statement_timeout = 0;\n" +
			"CREATE TABLE users (id int);\n"
		require.Equal(t, expected, string(out))
	})

	t.Run("preserves non-backslash content", func(t *testing.T) {
		in := "-- This is a comment\n" +
			"CREATE TABLE test (name varchar(100));\n" +
			"INSERT INTO test VALUES ('hello\\world');\n"
		out, err := dbutil.StripPsqlMetaCommands([]byte(in))
		require.NoError(t, err)
		require.Equal(t, in, string(out))
	})
}
