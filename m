From: "Andriy Korud" <a.korud@vector.com.pl>
Subject: RE: Re: [Prism54-users] Open hardware wireless cards
Date: Wed, 5 Jan 2005 23:34:02 +0100
Message-ID: <60E856FD577CC04BA3727AF4122D3F161134B8@3bit.vector.com.pl>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Netdev <netdev@oss.sgi.com>,
	Jean Tourrilhes <jt@bougret.hpl.hp.com>,
	"Luis R. Rodriguez" <mcgrof@studorgs.rutgers.edu>,
	prism54-devel@prism54.org, linux-kernel@vger.kernel.org,
	prism54-users@prism54.org, Jeff Garzik <jgarzik@pobox.com>
Return-path: <prism54-devel-bounces@prism54.org>
Content-class: urn:content-classes:message
To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>,
	"Steve Hill" <steve@nexusuk.org>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


> AFAICT the FullMAC chipsets have reached the END OF LIFE period.

Sorry, as I know (no more details - NDA, sorry) some manufacturers are =
developing (and planning to continue) FullMAC 802.11g (and further) =
chipsets and also they are offering Linux drivers (however had no chance =
to test yet).

But from my point of view, SoftMAC cards are better sometimes - you have =
more control from drivers and can implement some interesting features =
(for example, madwifi Linux driver with MAC layer ported from xBSD).=20

Any thoughts why we should prefer FullMAC cards over SoftMAC (except CPU =
usage, of course)?

regards,

--

Andriy Korud=20
