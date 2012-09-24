From: Oliver Neukum <oneukum@suse.de>
Subject: Re: removing the timer from cdc-ncm
Date: Mon, 24 Sep 2012 14:15:44 +0200
Message-ID: <3597001.EfZsdKS2P9@linux-lqwf.site>
References: <6020948.EvS2esPpc0@linux-lqwf.site> <2AC7D4AD8BA1C640B4C60C61C8E520154A8BED545F@EXDCVYMBSTM006.EQ1STM.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "bjorn@mork.no" <bjorn@mork.no>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Alexey ORISHKO <alexey.orishko@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40281 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754599Ab2IXMRW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 08:17:22 -0400
In-Reply-To: <2AC7D4AD8BA1C640B4C60C61C8E520154A8BED545F@EXDCVYMBSTM006.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 24 September 2012 14:13:50 Alexey ORISHKO wrote:

> I've tried to apply it, but always got a message that "patch does not apply".
> What is the base for this patch?

Greg KH's tree, specifically commit 6dab7ede9390d4d937cb89feca932e4fd575d2da

	HTH
		Oliver
