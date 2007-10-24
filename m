From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 1/6] Convert bonding timers to workqueues
Date: Tue, 23 Oct 2007 21:13:49 -0400
Message-ID: <20071024011349.GL9140@gospo.rdu.redhat.com>
References: <1192667871139-git-send-email-fubar@us.ibm.com> <1192667875793-git-send-email-fubar@us.ibm.com> <471E94F3.5050407@garzik.org> <7923.1193187601@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40413 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752807AbXJXBSg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Oct 2007 21:18:36 -0400
Content-Disposition: inline
In-Reply-To: <7923.1193187601@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 23, 2007 at 06:00:01PM -0700, Jay Vosburgh wrote:
> Jeff Garzik <jeff@garzik.org> wrote:
> 
> >applied patches 1-6
> 
> 	Thanks.
> 
> >However, two issues:
> >
> >1) Credit.  Did Andy write these, as the Signed-off-by lines indicate? 
> 
> 	Andy did some of it and I did some of it, so I presume that dual

I was just getting ready to post the same thing.  Jay beat me to it!

> Signed-off-by is correct (vs. one Signed-off and one Acked).
> 

I figured the dual 'Signed-off-by:' was the best way too since I didn't
think Linus had dual 'From:' lines.


> >2) vague subject line. [...]
> 
> 	Sorry about that; will keep it in mind next time.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
