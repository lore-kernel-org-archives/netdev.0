From: Steve Hill <steve@nexusuk.org>
Subject: Re: Open hardware wireless cards
Date: Wed, 5 Jan 2005 20:22:10 +0000 (GMT)
Message-ID: <Pine.LNX.4.61.0501052017380.5818@rivendell.nexusuk.org>
References: <20050105200526.GL5159@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Netdev <netdev@oss.sgi.com>,
	Jean Tourrilhes <jt@bougret.hpl.hp.com>,
	Jeff Garzik <jgarzik@pobox.com>, linux-kernel@vger.kernel.org,
	prism54-users@prism54.org, prism54-devel@prism54.org
Return-path: <prism54-users-bounces@prism54.org>
To: "Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>
In-Reply-To: <20050105200526.GL5159@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-users>,
	<mailto:prism54-users-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-users>
List-Post: <mailto:prism54-users@prism54.org>
List-Help: <mailto:prism54-users-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-users>,
	<mailto:prism54-users-request@prism54.org?subject=subscribe>
Sender: prism54-users-bounces@prism54.org
Errors-To: prism54-users-bounces@prism54.org
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On Wed, 5 Jan 2005, Luis R. Rodriguez wrote:

> What I think we probably will have to do is just work torwards seeing if
> we can come up with our own open wireless hardware. I know there was
> a recent thread on lkml about an open video card -- anyone know where
> that ended up?

This may be a silly point, but there *was* good 802.11g hardware available 
which worked well with the fully open drivers.  I presume the 
manufacturers are moving to the "softmac" design instead because (for 
them) it is cheaper.  However, the point is that the working designs are 
already there and it may be that buying the existing design which is being 
phased out is cheaper for the FOSS community than developing a whole new 
open device.

Maybe it would be possible to convince one of the manufacturers that it's 
worth their while producing the older design hardware - if there is a 
single manufacturer who is making more or less the only hardware that is 
guaranteed to work under Linux there is probably quite a market for them.

  - Steve       Jabber: steve@nexusuk.org     Web: http://www.nexusuk.org/

      Servatis a periculum, servatis a maleficum - Whisper, Evanescence

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)
Comment: Public key available at http://www.nexusuk.org/pubkey.txt

iD8DBQFB3Ex15zUOsIV3bqERAuInAKCGVS1kzaR4En2nQnKhDPv6TptZ+QCdEzFN
y8HbDEpnxvJql8AVpDePcnA=
=NfEa
-----END PGP SIGNATURE-----
