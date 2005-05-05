From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: [proski@gnu.org: [PATCH] Mailing lists, homepage for orinoco driver]
Date: Thu, 5 May 2005 10:27:59 +1000
Message-ID: <20050505002759.GB18270@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Roskin <proski@gnu.org>, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261975AbVEEA2P@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think this can go straight to Andrew and Linus, without having to go
via netdev.  Andrew, please apply.

Acked-by: David Gibson <hermes@gibson.dropbear.id.au>


----- Forwarded message from Pavel Roskin <proski@gnu.org> -----

Subject: [PATCH] Mailing lists, homepage for orinoco driver
From: Pavel Roskin <proski@gnu.org>
To: David Gibson <hermes@gibson.dropbear.id.au>, netdev@oss.sgi.com
Date: Thu, 21 Apr 2005 22:23:23 -0400

Hello!

Please add mailing list addresses for Orinoco and update its homepage.

Signed-off-by: Pavel Roskin <proski@gnu.org>

MAINTAINERS: 4333b69e56bdefdbc30858e0d4ccaf887d9b2ae0
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1699,7 +1699,9 @@ P:	Pavel Roskin
 M:	proski@gnu.org
 P:	David Gibson
 M:	hermes@gibson.dropbear.id.au
-W:	http://www.ozlabs.org/people/dgibson/dldwd
+L:	orinoco-users@lists.sourceforge.net
+L:	orinoco-devel@lists.sourceforge.net
+W:	http://www.nongnu.org/orinoco/
 S:	Maintained
 
 PARALLEL PORT SUPPORT


-- 
Regards,
Pavel Roskin


----- End forwarded message -----

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson
