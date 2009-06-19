From: Nivedita Singhvi <niv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] man page update (ip.7) to reflect new socket option in 2.6.31
Date: Fri, 19 Jun 2009 00:02:21 -0700
Message-ID: <4A3B37FD.4040801@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds the IP_MULTICAST_ALL option to
the ip.7 man page, to bring it up to date with
2.6.31 development.


Signed-off-by: Nivedita Singhvi <niv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

---
  man7/ip.7 |   10 +++++++++-
  1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/man7/ip.7 b/man7/ip.7
index ab866a1..6932ba2 100644
--- a/man7/ip.7
+++ b/man7/ip.7
@@ -357,7 +357,6 @@ and retrieve the MTU by calling
  with the
  .B IP_MTU
  option.
