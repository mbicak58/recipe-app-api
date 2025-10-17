"""
Test custom Django management commands.
"""

# Ersetzt echte Funktionen im Test durch simulierte („mocks“)
from unittest.mock import patch

# Fehler, wenn PostgreSQL sich nicht verbinden kann
from psycopg2 import OperationalError as Psycopg2Error

# Führt Django-Commands im Test aus, er ruft den comman auf den wir testen
from django.core.management import call_command

# Django-spezifischer DB-Verbindungsfehler, je nach dem welcher error kommt
from django.db.utils import OperationalError

# Einfache Testklasse ohne Datenbankanbindung
from django.test import SimpleTestCase


# das ist patched_check parameter
@patch("core.management.commands.wait_for_db.Command.check")
class CommandTests(SimpleTestCase):
    """Test commands."""

    def test_wait_for_db_ready(self, patched_check):
        """Test waiting for database if database ready."""
        patched_check.return_value = True

        # es checkt ob die verbindung gemacht wird und ob die funktion funktioniert
        call_command("wait_for_db")

        # hier wird gecheckt dass das richtige gecheckt wird
        patched_check.assert_called_once_with(databases=["default"])

    @patch("time.sleep")  # das ist patched_sleep parameter
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """Test waiting for database when getting OperationalError."""
        patched_check.side_effect = (
            [Psycopg2Error] * 2 + [OperationalError] * 3 + [True]
        )
        # * 3 we raise operational error

        call_command("wait_for_db")

        self.assertEqual(patched_check.call_count, 6)
        # making sure the patch database is checking the right (same 'database=['default']')
        patched_check.assert_called_with(databases=["default"])

        # check the db
        # wait a few seconds
        # check again
        # we dont wait in our unitest bc that would slow it down
