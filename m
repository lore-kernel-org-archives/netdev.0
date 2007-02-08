From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] cxgb3 - convert to user struct device instead of class_device
Date: Thu, 08 Feb 2007 13:31:10 -0800
Message-ID: <adad54kwd41.fsf@cisco.com>
References: <adalkj8l6vb.fsf@cisco.com> <20070208211911.GA20988@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, Divy Le Ray <divy@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>,
	netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:7938 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423420AbXBHVbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:31:37 -0500
In-Reply-To: <20070208211911.GA20988@suse.de> (Greg KH's message of "Thu, 8 Feb 2007 13:19:11 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > But I think Jeff already has a patch in the queue that makes this very
 > change :)

Really?  I'm not sure I looked everywhere in Jeff's maze of git
branches but I didn't see anything obvious in netdev-2.6.git when I
looked before sending this.

 - R.
