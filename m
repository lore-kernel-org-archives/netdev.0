From: =?iso-8859-1?q?Hans-J=FCrgen_Koch?= <hjk@linutronix.de>
Subject: Re: [PATCH] Fix a lock problem in generic phy code
Date: Thu, 13 Sep 2007 11:50:29 +0200
Message-ID: <200709131150.30609.hjk@linutronix.de>
References: <200708311430.09590.hjk@linutronix.de> <46E8B8C4.5010203@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	afleming@freescale.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754344AbXIMJum@vger.kernel.org>
In-Reply-To: <46E8B8C4.5010203@garzik.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Donnerstag 13 September 2007 schrieb Jeff Garzik:
> Hans-J=FCrgen Koch wrote:
> > Lock debugging finds a problem in phy.c and phy_device.c,
> > this patch fixes it. Tested on an AT91SAM9263-EK board,
> > kernel 2.6.23-rc4.
> >
> > Signed-off-by: Hans J. Koch <hjk@linutronix.de>
>
> applied

Thanks! Andrew applied it to -mm, too.

Hans
