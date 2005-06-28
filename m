From: Jiri Benc <jbenc@suse.cz>
Subject: ieee80211 patches
Date: Tue, 28 Jun 2005 14:23:05 +0200
Message-ID: <20050628142305.349d70fd@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, jbohac@suse.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Our patches against latest ieee80211 branch of netdev tree can be found at
http://forge.novell.com/modules/xfmod/cvs/cvsbrowse.php/ieee80211/patches-upstream/
(it is possible to download a tarball from this link too).

For CVS checkout enter
cvs -z3 -d:ext:anonymous@forgecvs1.novell.com:/cvsroot/ieee80211 co patches-upstream

Patches have to be applied in order specified in 'series' file (e. g.
using quilt).

Jeff, should we also post those patches to netdev?

 Jiri Benc and Jirka Bohac


-- 
Jiri Benc
SUSE Labs
