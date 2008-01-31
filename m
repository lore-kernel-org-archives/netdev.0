From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1][NETNS] Add missing initialization of
 nl_info.nl_net in rtm_to_fib6_config()
Date: Wed, 30 Jan 2008 19:09:46 -0800 (PST)
Message-ID: <20080130.190946.218924040.davem@davemloft.net>
References: <20080124103220.265806220@theryb.frec.bull.fr>
	<20080124103619.032868994@theryb.frec.bull.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, den@sw.ru, dlezcano@fr.ibm.com
To: benjamin.thery@bull.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54608
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1764551AbYAaDJ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 22:09:26 -0500
In-Reply-To: <20080124103619.032868994@theryb.frec.bull.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Thery <benjamin.thery@bull.net>
Date: Thu, 24 Jan 2008 11:32:21 +0100

> Add missing initialization of the new nl_info.nl_net field in 
> rtm_to_fib6_config(). This will be needed the store network namespace
> associated to the fib6_config struct.
> 
> Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>

Applied, thanks.
