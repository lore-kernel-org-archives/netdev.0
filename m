From: Jeff Garzik <jeff@garzik.org>
Subject: Re: has ethtool been patched for 10 gig speed reporting?
Date: Tue, 27 Mar 2007 15:42:24 -0400
Message-ID: <460973A0.8020803@garzik.org>
References: <460968FD.4020202@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38552 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932140AbXC0Tm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 15:42:28 -0400
In-Reply-To: <460968FD.4020202@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> I have some 10gig nics and ethtool is reporting unknown for the speed. 
> Is there already a patch, or have I found an opportunity? FWIW, the 
> version five bits from sourceforge still report unknown - are they the 
> latest or are there later bits somewhere?

Nope, patches welcome.  A couple people did minimalist patches, that 
didn't apply to ethtool.git, and didn't update any of the associated 
docs.  I asked for an update and don't see any reply.

	Jeff



