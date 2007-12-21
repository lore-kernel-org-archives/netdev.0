From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] OOPS with NETLINK_FIB_LOOKUP netlink socket
Date: Fri, 21 Dec 2007 01:59:36 -0800 (PST)
Message-ID: <20071221.015936.124513863.davem@davemloft.net>
References: <20071221090043.GA25484@iris.sw.ru>
	<20071221.013321.164620125.davem@davemloft.net>
	<476B89D8.2060602@sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, devel@openvz.org, netdev@vger.kernel.org,
	kaber@trash.net, kuznet@ms2.inr.ac.ru
To: den@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60776
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750695AbXLUJ7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:59:36 -0500
In-Reply-To: <476B89D8.2060602@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@sw.ru>
Date: Fri, 21 Dec 2007 12:39:36 +0300

> David Miller wrote:
> > What introduced this bug?  This code didn't have this
> > problem previously.
> 
> commit cd40b7d3983c708aabe3d3008ec64ffce56d33b0
> Author: Denis V. Lunev <den@openvz.org>
> Date:   Wed Oct 10 21:15:29 2007 -0700

Thank you, I'm going to add this reference to the changeset
comments so that it will help others who look at this fix.

Consider your patch applied, thanks! :-)
