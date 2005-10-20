From: Bernd Jendrissek <berndj@prism.co.za>
Subject: Re: [PATCH] X25: Add ITU-T facilites
Date: Thu, 20 Oct 2005 09:41:29 +0200
Message-ID: <20051020074129.GA13695@prism.co.za>
References: <1129513666.3747.50.camel@localhost.localdomain> <20051017022826.GA23167@mandriva.com> <1129615767.3695.15.camel@localhost.localdomain> <20051018.152318.68554424.yoshfuji@linux-ipv6.org> <20051018153702.GC23167@mandriva.com> <Pine.LNX.4.61.0510181144320.28065@chaos.analogic.com> <1129770654.3574.1154.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-os (Dick Johnson)" <linux-os@analogic.com>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
	eis@baty.hanse.de, linux-x25@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-x25-owner@vger.kernel.org>
To: Andrew Hendry <ahendry@tusc.com.au>
Content-Disposition: inline
In-Reply-To: <1129770654.3574.1154.camel@localhost.localdomain>
Sender: linux-x25-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Thu, Oct 20, 2005 at 11:10:54AM +1000, Andrew Hendry wrote:
> __u32 or unsigned int look to be the norm for other similar headers,
> whats the recommended type of types to be used?

Dunno if this helps, but AFAIK the C language (as of 1999 or is it 2000)
blesses uint32_t and friends.

Indeed, <linux/types.h> (in the kernel source tree) defines these
*standard* sized types.

HTH

- -- 
A PC without Windows is like ice cream without ketchup.
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)
Comment: Please fetch my new key 804177F8 from hkp://wwwkeys.eu.pgp.net/

iD8DBQFDV0ohwyMv24BBd/gRAnOAAKCpTJLsIIQCGW4X/KMyoIMwZ0TNewCff2vE
IO7gmOpr1zuFa515lmIPWno=
=uytG
-----END PGP SIGNATURE-----
