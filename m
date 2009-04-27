From: Karsten Keil <karsten-keil@t-online.de>
Subject: Re: [PATCH v2 0/3] [ISDN] Documentation patchset
Date: Mon, 27 Apr 2009 15:13:32 +0200
Message-ID: <200904271513.32728.karsten-keil@t-online.de>
References: <cover.1240489461.git.keil@b1-systems.de> <200904271345.35345.karsten-keil@t-online.de> <20090427.053902.262806706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout10.t-online.de ([194.25.134.21]:40431 "EHLO
	mailout10.t-online.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729AbZD0NOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 09:14:01 -0400
In-Reply-To: <20090427.053902.262806706.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, 27. April 2009 14:39:02 you wrote:
...
>
> Here they are in patchwork, they don't apply:
>
> http://patchwork.ozlabs.org/patch/26362/
> http://patchwork.ozlabs.org/patch/26363/
> http://patchwork.ozlabs.org/patch/26361/
>
> Oh I see what happened.
>
> IT'S THOSE STUPID "Date:" fields you added to the body of 2 of those
> patches.  It caused patchwork to put them in the wrong order when I
> put them together into a bundle.
>
> Don't add extra email header fields like that, please! :-)
>
> I fixed it up and applied the patches.

Thanks,  sorry for the extra work.

I did add the headers (Date and From) to preserve the ownership and original 
date, with plain git it works very well.

I can leave out the date field, but if I resend  patch from a other developer 
(which I signed or acked as maintainer), I need to move the original From into 
the body, my uplink rewrites the From with my address. Would this be still OK 
or does the From in the body make also problems with patchwork ?

Other way would be to setup a cloned net-2.6 isdn tree, so you can pull 
patches directly.

Karsten

