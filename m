From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] tg3: add amd8131 to "write reorder" chipsets
Date: Fri, 7 Jul 2006 15:21:11 -0400
Message-ID: <20060707192106.GD22636@tuxdriver.com>
References: <20060707185831.GC22636@tuxdriver.com> <20060707.121220.99179918.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:40197 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S932270AbWGGTV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 15:21:27 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060707.121220.99179918.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 07, 2006 at 12:12:20PM -0700, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Fri, 7 Jul 2006 14:58:36 -0400
> 
> > Add the AMD 8131 bridge to the list of chipsets that reorder writes.
> > 
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> 
> What failure report is this chipset blacklist addition based
> upon?  I just want to look at the paper trail before adding
> this.

What?  Due diligence?  You must be joking!!!  :-)

	https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=174019#c48

Hth!

John
-- 
John W. Linville
linville@tuxdriver.com
