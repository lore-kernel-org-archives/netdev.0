From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: fix a few Kconfig imperfections
Date: Mon, 22 Feb 2010 15:48:11 -0800 (PST)
Message-ID: <20100222.154811.175887702.davem@davemloft.net>
References: <20100222210938.75A3B4011D@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, keil@b1-systems.de,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: tilman@imap.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100222210938.75A3B4011D@xenon.ts.pxnet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Date: Mon, 22 Feb 2010 22:09:38 +0100 (CET)

> 1. Rewrite the outdated help texts for config options ISDN and ISDN_CAPI.
> 2. The MISDN config option appeared between ISDN_I4L and the I4L hardware
>    driver options; move it to a less irritating place.
> 3. HYSDN is not in fact an I4L driver, and needn't depend on ISDN_I4L, so
>    move it from the I4L section to the general section.
> 4. ISDN_HDLC is now also used by drivers outside I4L.  Move it from the
>    I4L section to the general section, too.
> 
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>

Applied.
