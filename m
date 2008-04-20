From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch 1/3] hci_usb: do not initialize static variables to 0
Date: Sat, 19 Apr 2008 18:14:14 -0700 (PDT)
Message-ID: <20080419.181414.174853322.davem@davemloft.net>
References: <200804182046.m3IKkp7P014625@imap1.linux-foundation.org>
	<A7F393C1-AEAC-4BC5-B7A4-A9CC78179CDF@holtmann.org>
	<20080419161245.GA1577@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: pavel-+ZI9xUNit7I@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080419161245.GA1577-I/5MKhXcvmPrBKCeMvbIDA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>
Date: Sat, 19 Apr 2008 18:12:45 +0200

> According to you noone should read this one, anyway :-)... and this
> wastes space in vmlinux.

This is getting rediculious :-)

I've applied this patch.
