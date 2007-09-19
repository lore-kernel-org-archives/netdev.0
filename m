From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: Please pull 'p54' branch of wireless-2.6
Date: Wed, 19 Sep 2007 22:04:05 +0100
Message-ID: <20070919210405.GA2231@infradead.org>
References: <20070919195527.GD5483@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michael Wu <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070919195527.GD5483-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 19, 2007 at 03:55:27PM -0400, John W. Linville wrote:
>  drivers/net/wireless/Kconfig     |   13 +
>  drivers/net/wireless/Makefile    |    4 +
>  drivers/net/wireless/net2280.h   |  452 +++++++++++++++++
>  drivers/net/wireless/p54.h       |   80 +++
>  drivers/net/wireless/p54common.c |  983 ++++++++++++++++++++++++++++++++++++++
>  drivers/net/wireless/p54common.h |  329 +++++++++++++
>  drivers/net/wireless/p54pci.c    |  689 ++++++++++++++++++++++++++
>  drivers/net/wireless/p54pci.h    |  106 ++++
>  drivers/net/wireless/p54usb.c    |  904 +++++++++++++++++++++++++++++++++++
>  drivers/net/wireless/p54usb.h    |  133 +++++

PLease put it into a separate subdirectory, thanks.

Also net2280.h seems rather oddly named.
