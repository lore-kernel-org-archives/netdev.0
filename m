From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next 2/3] ethtool: add rx_copybreak support
Date: Wed, 23 Jul 2014 00:42:00 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1407230039010.15542@ws.cisco>
References: <1406050268-13329-1-git-send-email-_govind@gmx.com>   <1406050268-13329-3-git-send-email-_govind@gmx.com>  <1406051145.7427.2.camel@deadeye.wl.decadent.org.uk>  <alpine.LNX.2.03.1407230004150.15542@ws.cisco>
 <1406055025.7427.7.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:58726 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751185AbaGVTMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 15:12:40 -0400
In-Reply-To: <1406055025.7427.7.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Jul 2014, Ben Hutchings wrote:
> No, you can't do that either.  Basically you can't change the size or
> layout of any of the ethtool structures.

Ok. Can you suggest me how I should add rx_copybreak to ethtool?

May be add another function, set/get_rxcopybreak(), to ethtool_ops?

Thanks
