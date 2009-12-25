From: Valdis.Kletnieks@vt.edu
Subject: Re: [Patch] tipc: use kconfig to limit numeric ranges
Date: Thu, 24 Dec 2009 22:50:06 -0500
Message-ID: <31665.1261713006@localhost>
References: <20091225032956.4556.69130.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1261713006_3923P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Allan Stephens <allan.stephens@windriver.com>,
	netdev@vger.kernel.org, Per Liden <per.liden@ericsson.com>,
	tipc-discussion@lists.sourceforge.net, akpm@linux-foundation.org,
	Jon Maloy <jon.maloy@ericsson.com>
To: Amerigo Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755245AbZLYDuz@vger.kernel.org>
In-Reply-To: Your message of "Thu, 24 Dec 2009 22:26:48 EST."
             <20091225032956.4556.69130.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1261713006_3923P
Content-Type: text/plain; charset=us-ascii

On Thu, 24 Dec 2009 22:26:48 EST, Amerigo Wang said:
> We can rely on kconfig to limit these numbers,
> no need to limit them at compile time/run time.

> +          ***Only 1 (one cluster in a zone) is supported by current code.***
>  
>            (Max number of clusters inside TIPC zone. Max supported 
>            value is 4095 clusters, minimum is 1.

Given the limit of 1, maybe the reference to 4095 should be nuked?


--==_Exmh_1261713006_3923P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLNDZucC3lWbTT17ARAlxzAKDRM8KKzDY0zYl/wAFUChvTd/vmbQCfT+j3
mdckI3qPC5/4Wm2p1UrX1RE=
=DpWr
-----END PGP SIGNATURE-----

--==_Exmh_1261713006_3923P--
