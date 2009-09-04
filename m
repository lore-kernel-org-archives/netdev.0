From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next] can: add can_free_echo_skb() for upcoming drivers
Date: Fri, 04 Sep 2009 07:27:15 +0200
Message-ID: <4AA0A533.1060507@hartkopp.net>
References: <4A9D3D14.90201@grandegger.com>
	<20090903.204641.193482962.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org,
	urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20090903.204641.193482962.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Can a CAN expert please review these patches?  They are rotting
> in patchwork and I want to move forward with them somehow.

Hello Dave,

Wolfgang *is* the CAN expert for CAN drivers :-)

We've split the things up:

CAN network layer: Oliver Hartkopp / Urs Thuermann
CAN network drivers: Wolfgang Grandegger

As written in MAINTAINERS:

CAN NETWORK DRIVERS
M:      Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
L:      socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org (subscribers-only)
W:      http://developer.berlios.de/projects/socketcan/
S:      Maintained

Btw. All three patches sitting in patchwork are ok from my side and i've
personally reviewed them. I thought that Wolfgang was already known to
maintain this stuff, so i did not put my Acked-by ...

Best regards,
Oliver
