From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 00/62] drivers/net: Use static const
Date: Tue, 23 Nov 2010 08:28:00 -0800 (PST)
Message-ID: <20101123.082800.189699339.davem@davemloft.net>
References: <1290463846.27683.36.camel@Joe-Laptop>
	<20101122.141939.226774888.davem@davemloft.net>
	<1290465605.27683.52.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ath5k-devel-xDcbHBWguxEUs3QNXV6qNA@public.gmane.org, libertas-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	e1000-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org
To: joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1290465605.27683.52.camel@Joe-Laptop>
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

From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Date: Mon, 22 Nov 2010 14:40:05 -0800

> I'll see who picks up or acks what and send a pull request to
> you for the remainder of these patches mid December or so.

Thanks.

> Do you want micro patches or a single patch?

You can group them by directory or similar if you like.

F.e.:

Patch 1: drivers/net/*.c
Patch 2: drivers/net/*/*.c (wired drivers)
Patch 3: drivers/net/wireless/*

Thanks again.
