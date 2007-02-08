From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] cxgb3 - convert to user struct device instead of class_device
Date: Thu, 8 Feb 2007 17:48:08 -0600
Message-ID: <8CA2F311-CAFF-48C3-AC84-68FF6486FB35@kernel.crashing.org>
References: <adalkj8l6vb.fsf@cisco.com> <20070208211911.GA20988@suse.de> <adad54kwd41.fsf@cisco.com> <45CB9A24.1030509@garzik.org> <adaps8kux3y.fsf@cisco.com>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Greg KH <gregkh@suse.de>,
	Divy Le Ray <divy@chelsio.com>,
	Steve Wise <swise@opengridcomputing.com>,
	netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:13141 "EHLO
	nommos.sslcatacombnetworking.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965373AbXBHXtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 18:49:21 -0500
In-Reply-To: <adaps8kux3y.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 8, 2007, at 4:02 PM, Roland Dreier wrote:

>> Andrew told me to drop it, so I dropped it :)
>
> That's odd -- do you know why?  drivers/net/cxgb3 won't build at all
> in Linus's tree.  I would have thought we want to fix it ASAP.

I've posted a similar patch for drivers/net/gianfar_sysfs.c that is  
needed for it to build in linus's tree.

- k
