From: Valdis.Kletnieks@vt.edu
Subject: Re: Divide error in bictcp_cong_avoid ?
Date: Wed, 04 May 2011 16:01:10 -0400
Message-ID: <18029.1304539270@localhost>
References: <20110504113351.4643a0c9@nehalam> <16668.1304537481@localhost> <20110504123738.7bb4d1ee@nehalam>
            <20110504.124053.260068550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1304539270_7352P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, rdunlap@xenotime.net, lkml@techboom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Wed, 04 May 2011 12:40:53 PDT."
             <20110504.124053.260068550.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1304539270_7352P
Content-Type: text/plain; charset=us-ascii

On Wed, 04 May 2011 12:40:53 PDT, David Miller said:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 4 May 2011 12:37:38 -0700
> 
> > Don't use BIC, it is known to be unfair between flows.
> 
> That doesn't fix the user's bug, nothing in the kernel should causes
> crashes under normal circumstances.

And if it's a "don't use" thing, maybe it's time to deprecate it and/or
otherwise discourage its use? I know *my* config still has it mostly because it
*seems* to work, and nothing's suggested I should change it.



--==_Exmh_1304539270_7352P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNwbCGcC3lWbTT17ARAoNeAJ99X/1K3NKGpSosgJn2P5+uffUwDQCg4Geh
Ip48yld8OQT4ccNOxFX7FI0=
=EF5Z
-----END PGP SIGNATURE-----

--==_Exmh_1304539270_7352P--
