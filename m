From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [PATCH 04/17] batman-adv: document sysfs files in
	alphabetical order
Date: Fri,  1 Jul 2016 15:08:56 +0200
Message-ID: <1467378549-9646-5-git-send-email-sw@simonwunderlich.de>
References: <1467378549-9646-1-git-send-email-sw@simonwunderlich.de>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1467378549-9646-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

From: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>

Also update obsolete email address.

Signed-off-by: Marek Lindner <mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org>
Acked-by: Antonio Quartulli <a@unstable.cc>
Signed-off-by: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
---
 Documentation/ABI/testing/sysfs-class-net-batman-adv | 18 +++++++++-----=
----
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-class-net-batman-adv b/Docum=
entation/ABI/testing/sysfs-class-net-batman-adv
index 518f6a1..77d3083 100644
--- a/Documentation/ABI/testing/sysfs-class-net-batman-adv
+++ b/Documentation/ABI/testing/sysfs-class-net-batman-adv
@@ -1,13 +1,4 @@
=20
-What:		/sys/class/net/<iface>/batman-adv/throughput_override
-Date:		Feb 2014
-Contact:	Antonio Quartulli <antonio-x4xJYDvStAgysxA8WJXlww@public.gmane.org>
-description:
-		Defines the throughput value to be used by B.A.T.M.A.N. V
-		when estimating the link throughput using this interface.
-		If the value is set to 0 then batman-adv will try to
-		estimate the throughput by itself.
-
 What:           /sys/class/net/<iface>/batman-adv/elp_interval
 Date:           Feb 2014
 Contact:        Linus L=C3=BCssing <linus.luessing-S0/GAf8tV78@public.gmane.org>
@@ -28,3 +19,12 @@ Description:
                 The /sys/class/net/<iface>/batman-adv/mesh_iface file
                 displays the batman mesh interface this <iface>
                 currently is associated with.
+
+What:           /sys/class/net/<iface>/batman-adv/throughput_override
+Date:           Feb 2014
+Contact:        Antonio Quartulli <a@unstable.cc>
+description:
+                Defines the throughput value to be used by B.A.T.M.A.N. =
V
+                when estimating the link throughput using this interface=
.
+                If the value is set to 0 then batman-adv will try to
+                estimate the throughput by itself.
--=20
2.8.1
