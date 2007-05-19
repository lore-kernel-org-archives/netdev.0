From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] libertas: skb dereferenced after netif_rx
Date: Sat, 19 May 2007 01:37:00 -0400
Message-ID: <464E8CFC.8070801@garzik.org>
References: <464B7127.5080502@gmail.com>	<20070518180903.GC3492@tuxdriver.com> <20070518222308.11c2b34d@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Florin Malita <fmalita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, marcelo-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org,
	linville-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070518222308.11c2b34d@localhost>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> netif_rx() used to return a value in older kernels.

netif_rx() returns a value in current kernels.

	Jeff
