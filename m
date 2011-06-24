From: Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: Re: [uclinux-dist-devel] [PATCH 1/2] can: bfin_can: simplify xmit id1
	setup
Date: Fri, 24 Jun 2011 10:32:21 -0400
Message-ID: <BANLkTi=wxiu9EG86B5zxP9R+8M6+z1tcdQ@mail.gmail.com>
References: <1308861380-27485-1-git-send-email-vapier@gentoo.org>
	<4E046AFE.5000109@volkswagen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Urs Thuermann <urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
To: Oliver Hartkopp <oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4E046AFE.5000109-l29pVbxQd1IUtdQbppsyvg@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 24, 2011 at 06:46, Oliver Hartkopp wrote:
> In MAINTAINERS there are entries for the CAN NETWORK LAYER and for CAN
> NETWORK DRIVERS which addresses the code in drivers/net/can/...

hmm, wonder when this changed.  oh well, updated local .git/mail now.

> Additionally you should address your patch to the author of the driver
> (Barry Song <21cnbao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>).

he's already in the cc list.  he's an ADI employee (like me) who
watches the Blackfin mailing lists.
-mike
