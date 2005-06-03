From: Jiri Benc <jbenc@suse.cz>
Subject: [0/9] ieee80211: Improvements to the layer
Date: Fri, 3 Jun 2005 18:26:25 +0200
Message-ID: <20050603182625.64d33be3@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Jirka Bohac <jbohac@suse.cz>
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Following patches are nearly the same as were sent couple of days ago.
However, they are against current netdev-2.6 tree and they contain some
more fixes (TKIP compilation, new file for protocol layer functions).

The HH_DATA_OFF bugfix is needed too
(http://oss.sgi.com/projects/netdev/archive/2005-05/msg00962.html), it's
not included here as it is in Linus' tree already.

Also there are two patches from Adrian Bunk included.


-- 
Jiri Benc
SUSE Labs
