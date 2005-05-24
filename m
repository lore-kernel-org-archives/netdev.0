From: Mateusz Berezecki <mateuszb@gmail.com>
Subject: ieee80211.h and DSSS PHY type
Date: Tue, 24 May 2005 14:38:57 +0200
Message-ID: <42932061.5050109@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi list members,


I got a quick question regarding modulation type defines in ieee80211.h
in netdev tree ieee80211 branch from current netdev git tree.

Isn't the #define IEEE80211_DSSS_MODULATION missing in the include file?
or am I plain wrong?
Im asking because atheros driver im writing is using some constant value
which needs some name;)
And after evaluating some IEEE pdf's this appears to be a DSSS PHY type
and numeric constants do not
 look good in source code.


regards
/mb
