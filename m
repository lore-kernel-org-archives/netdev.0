From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] sky2: don't do GRO on second port
Date: Thu, 2 Sep 2010 18:48:23 +0200
Message-ID: <20100902164823.GA18597@del.dom.local>
References: <20100901145554.4f5abd80@nehalam>
 <20100902091839.GB6246@ff.dom.local>
 <20100902125326.GD8775@ff.dom.local>
 <20100902.093023.71114413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:63815 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997Ab0IBQsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 12:48:30 -0400
Received: by ewy23 with SMTP id 23so423585ewy.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 09:48:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100902.093023.71114413.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 02, 2010 at 09:30:23AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 2 Sep 2010 12:53:26 +0000
> 
> > Stephen, after Eric's explanation, I really think this patch was a bad
> > idea, and I apologize my false opinion started this.
> > 
> > I hope David, will revert this patch, please.
> 
> Ok, now that I've reread everything over I agree, I'll revert the
> sky2 change, thanks.

Thanks!
Jarek P.
