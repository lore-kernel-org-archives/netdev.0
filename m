From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] cxgb3 - convert to user struct device instead of class_device
Date: Fri, 09 Feb 2007 00:21:17 -0500
Message-ID: <45CC04CD.4080601@garzik.org>
References: <adalkj8l6vb.fsf@cisco.com> <20070208211911.GA20988@suse.de>	<adad54kwd41.fsf@cisco.com> <45CBE95E.20601@chelsio.com> <adabqk4m0iv.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Divy Le Ray <divy@chelsio.com>, Greg KH <gregkh@suse.de>,
	Steve Wise <swise@opengridcomputing.com>,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52466 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946105AbXBIFV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 00:21:26 -0500
In-Reply-To: <adabqk4m0iv.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > I pushed a fix in the -mm tree as soon as the driver got committed there.
>  > I saw the patch committed in Jeff's upstream branch yesterday.
>  > It looks like it did not make it to Linus'tree though.
> 
> OK, I missed that.  In any case cxgb3 in Linus's tree doesn't build
> right now.  What's the plan to fix this, Jeff?  Will you merge a fix
> through your tree?  I can resend the patch if you want, or send it
> directly to Andrew if that's preferred.

The fix has already been sent upstream.

	Jeff



