From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] cxgb3 - convert to user struct device instead of class_device
Date: Thu, 08 Feb 2007 20:13:12 -0800
Message-ID: <adabqk4m0iv.fsf@cisco.com>
References: <adalkj8l6vb.fsf@cisco.com> <20070208211911.GA20988@suse.de>
	<adad54kwd41.fsf@cisco.com> <45CBE95E.20601@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>, Jeff Garzik <jeff@garzik.org>,
	Steve Wise <swise@opengridcomputing.com>,
	netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:40485 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946080AbXBIENX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 23:13:23 -0500
In-Reply-To: <45CBE95E.20601@chelsio.com> (Divy Le Ray's message of "Thu, 08 Feb 2007 19:24:14 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > I pushed a fix in the -mm tree as soon as the driver got committed there.
 > I saw the patch committed in Jeff's upstream branch yesterday.
 > It looks like it did not make it to Linus'tree though.

OK, I missed that.  In any case cxgb3 in Linus's tree doesn't build
right now.  What's the plan to fix this, Jeff?  Will you merge a fix
through your tree?  I can resend the patch if you want, or send it
directly to Andrew if that's preferred.

 - R.
