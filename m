From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH] cxgb3 - convert to user struct device instead of class_device
Date: Thu, 08 Feb 2007 19:24:14 -0800
Message-ID: <45CBE95E.20601@chelsio.com>
References: <adalkj8l6vb.fsf@cisco.com> <20070208211911.GA20988@suse.de> <adad54kwd41.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Greg KH <gregkh@suse.de>, Jeff Garzik <jeff@garzik.org>,
	Steve Wise <swise@opengridcomputing.com>,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:13550 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946048AbXBIDYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 22:24:37 -0500
In-Reply-To: <adad54kwd41.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roland Dreier wrote:
>  > But I think Jeff already has a patch in the queue that makes this very
>  > change :)
>
> Really?  I'm not sure I looked everywhere in Jeff's maze of git
> branches but I didn't see anything obvious in netdev-2.6.git when I
> looked before sending this.
>
>  - R.
>   
I pushed a fix in the -mm tree as soon as the driver got committed there.
I saw the patch committed in Jeff's upstream branch yesterday.
It looks like it did not make it to Linus'tree though.

Cheers,
Divy
