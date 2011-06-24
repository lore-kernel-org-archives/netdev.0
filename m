From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 13/37] Remove unneeded version.h includes from drivers/net/
Date: Fri, 24 Jun 2011 02:40:22 -0700 (PDT)
Message-ID: <20110624.024022.829496490655572126.davem@davemloft.net>
References: <alpine.LNX.2.00.1106232344480.17688@swampdragon.chaosbits.net>
	<alpine.LNX.2.00.1106240017510.17688@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	rmody-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org, oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org, sathya.perla-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org,
	xeb-JGs/UdohzUI@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	ddutt-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org, shodgson-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	ajit.khaparde-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org, bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	subbu.seetharaman-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org, linux-net-drivers-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org,
	trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org, sjur.brandeland-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org
To: jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <alpine.LNX.2.00.1106240017510.17688-h2p7t3/P30RzeRGmFJ5qR7ZzlVVXadcDXqFh9Ls21Oc@public.gmane.org>
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

From: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>
Date: Fri, 24 Jun 2011 00:21:10 +0200 (CEST)

> It was pointed out by 'make versioncheck' that some includes of
> linux/version.h are not needed in drivers/net/.
> This patch removes them.
> 
> Signed-off-by: Jesper Juhl <jj-IYz4IdjRLj0sV2N9l4h3zg@public.gmane.org>

Applied, thanks.
