module IHP.IDE.Postgres (waitPostgresServer) where

import IHP.IDE.Types
import IHP.Prelude
import qualified System.Process as Process
import Control.Concurrent (threadDelay)
import GHC.IO.Handle

import qualified IHP.Log as Log
import qualified IHP.LibDir as LibDir

waitPostgresServer :: (?context :: Context) => IO ()
waitPostgresServer = do
    let isDebugMode = ?context |> get #isDebugMode
    threadDelay 1000000
    (_, stdout, _) <- Process.readProcessWithExitCode "pg_ctl" ["status"] ""
    if "server is running" `isInfixOf` (cs stdout)
    then dispatch (UpdatePostgresState PostgresReady)
    else do
        when isDebugMode (Log.debug ("Waiting for postgres to start" :: Text))
        waitPostgresServer
