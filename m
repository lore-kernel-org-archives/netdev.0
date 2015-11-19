From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH iptables] libxt_cgroup: improve wording in the man page
Date: Thu, 19 Nov 2015 13:58:01 -0500
Message-ID: <20151119185801.GC28608@mtj.duckdns.org>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	coreteam-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-team-b10kYP2dOMg@public.gmane.org,
	daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org,
	nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	kadlec-K40Dz/62t/MgiyqX0sVFJYdd74u8MsAO@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1447959171-20749-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Replace "disadviced" with "not advised" as suggested by Jan.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
---
 extensions/libxt_cgroup.man |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/extensions/libxt_cgroup.man
+++ b/extensions/libxt_cgroup.man
@@ -12,7 +12,7 @@ the net_cls cgroup's id.
 matcher is currently only of limited functionality, meaning it
 will only match on packets that are processed for local sockets
 through early socket demuxing. Therefore, general usage on the
-INPUT chain is disadviced unless the implications are well
+INPUT chain is not advised unless the implications are well
 understood.
 .PP
 Example:
