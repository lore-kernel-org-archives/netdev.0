From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: fix big endian MAC address collection failure
Date: Mon, 13 Apr 2009 14:44:18 -0700 (PDT)
Message-ID: <20090413.144418.242388332.davem@davemloft.net>
References: <1239636594.3278.31.camel@mulgrave.int.hansenpartnership.com>
	<20090413.143211.214694858.davem@davemloft.net>
	<1239658951.3278.104.camel@mulgrave.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
	mcarlson@broadcom.com, mchan@broadcom.com
To: James.Bottomley@HansenPartnership.com
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <1239658951.3278.104.camel@mulgrave.int.hansenpartnership.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 13 Apr 2009 21:42:31 +0000

> Actually, hang on ... I fat fingered the list address first time around
> and we've been replying on the wrong list.
> 
> Michael apparently has the code working for sparc and we're all a bit
> stumped why it doesn't work on parisc since they should follow identical
> code paths.
> 
> This is the latest state of play:

Too late, I already pushed out to my net-2.6 tree on kernel.org

You'll need to send me any fixups relative to this patch.

Thanks.
