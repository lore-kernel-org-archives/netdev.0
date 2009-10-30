From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix RPF to work with policy routing
Date: Thu, 29 Oct 2009 22:51:56 -0700 (PDT)
Message-ID: <20091029.225156.213496658.davem@davemloft.net>
References: <1255867954.4815.25.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, atis@mikrotik.com, eric.dumazet@gmail.com,
	zenczykowski@gmail.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49096
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754764AbZJ3Fvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 01:51:32 -0400
In-Reply-To: <1255867954.4815.25.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sun, 18 Oct 2009 08:12:33 -0400

> commit f7c6fd2465d8e6f4f89c5d1262da10b4a6d499d0
> Author: Jamal Hadi Salim <hadi@cyberus.ca>
> Date:   Sun Oct 18 08:04:51 2009 -0400
> 
>     [PATCH] net: Fix RPF to work with policy routing
>     Policy routing is not looked up by mark on reverse path filtering.
>     This fixes it.
>     
>     Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied to net-2.6, thanks.
