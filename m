From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] cxgb4: function namespace cleanup (v2)
Date: Mon, 18 Oct 2010 07:31:45 -0700 (PDT)
Message-ID: <20101018.073145.189710492.davem@davemloft.net>
References: <20101015212310.47a74d86@nehalam>
	<4CB9434D.1060702@chelsio.com>
	<4CBA6DC8.4010104@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dm@chelsio.com, shemminger@vyatta.com, divy@chelsio.com,
	leedom@chelsio.com, netdev@vger.kernel.org
To: swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755086Ab0JRObW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 10:31:22 -0400
In-Reply-To: <4CBA6DC8.4010104@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Wise <swise@opengridcomputing.com>
Date: Sat, 16 Oct 2010 22:30:16 -0500

> I'll add a patch this week to utilize the tcp stats.


Ok, thanks Steve.

Stephen, please respin the two cxgb4 patches without the
tcp stat function removal.
