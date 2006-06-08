From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCH 2.6.17-rc5 tulip free_irq() called too late
Date: Thu, 8 Jun 2006 09:47:06 -0600
Message-ID: <20060608154706.GG8246@colo.lackof.org>
References: <20060531195234.GA4967@colo.lackof.org> <44883778.8000209@pobox.com> <20060608152221.GC8246@colo.lackof.org> <20060608153235.GD8246@colo.lackof.org> <4488448C.8050504@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Val Henson <val.henson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:65245 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S964890AbWFHPrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2006 11:47:09 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4488448C.8050504@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2006 at 11:38:52AM -0400, Jeff Garzik wrote:
> >Can we call free_irq() from tulip_down()?
> 
> I'm sure you can answer that yourself.  If it doesn't cause problems 
> elsewhere, yes.  Otherwise, no.  :)

Yeah, well, I was hoping you would "Just Know" (tm). :)
Research takes time.

> Did you read the example I cited, cp_close() ?

Yes - after I sent the mail. It looks good to me too.

thanks,
grant
