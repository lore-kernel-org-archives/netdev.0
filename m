From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] cxgb4: function namespace cleanup (v3)
Date: Thu, 21 Oct 2010 04:30:16 -0700 (PDT)
Message-ID: <20101021.043016.45899923.davem@davemloft.net>
References: <20101018.073145.189710492.davem@davemloft.net>
	<20101018083918.3777a278@nehalam>
	<4CBCD548.3030005@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, swise@opengridcomputing.com,
	divy@chelsio.com, leedom@chelsio.com, netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43497
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757591Ab0JUL3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 07:29:53 -0400
In-Reply-To: <4CBCD548.3030005@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Mon, 18 Oct 2010 16:16:24 -0700

> Stephen Hemminger wrote:
>> Make functions only used in one file local.
>> Remove lots of dead code, relating to unsupported functions
>> in mainline driver like RSS, IPv6, and TCP offload.
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: Dimitris Michailidis <dm@chelsio.com>

Applied.
