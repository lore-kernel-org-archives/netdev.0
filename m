From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/8] Get rid of net_device_stats from
 adapter.
Date: Wed, 07 Oct 2009 22:01:15 -0700 (PDT)
Message-ID: <20091007.220115.224535606.davem@davemloft.net>
References: <20091007124129.GA29781@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ajitk@serverengines.com, ajitkhaparde@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33891
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751827AbZJHFBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 01:01:20 -0400
In-Reply-To: <20091007124129.GA29781@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ajit Khaparde <ajitkhaparde@gmail.com>
Date: Wed, 7 Oct 2009 18:11:40 +0530

> Since net_device already has an instance of net_device stats,
> its not necessary for the drivers to maintain their own copy
> in their private adapter structure.
> This patch series takes care of this for some of the drivers.
> I have compiled them all in my setup. 
> And not all of them have been tested.  :-)

All applied, thanks!
