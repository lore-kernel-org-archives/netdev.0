From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] cxgb3 - convert to user struct device instead of class_device
Date: Thu, 08 Feb 2007 14:02:09 -0800
Message-ID: <adaps8kux3y.fsf@cisco.com>
References: <adalkj8l6vb.fsf@cisco.com> <20070208211911.GA20988@suse.de>
	<adad54kwd41.fsf@cisco.com> <45CB9A24.1030509@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>, Divy Le Ray <divy@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:5683 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945911AbXBHWCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 17:02:12 -0500
In-Reply-To: <45CB9A24.1030509@garzik.org> (Jeff Garzik's message of "Thu, 08 Feb 2007 16:46:12 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > Andrew told me to drop it, so I dropped it :)

That's odd -- do you know why?  drivers/net/cxgb3 won't build at all
in Linus's tree.  I would have thought we want to fix it ASAP.

 - R.
