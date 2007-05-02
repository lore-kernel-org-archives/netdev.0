From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/20][BNX2]: Enhance the heartbeat.
Date: Wed, 02 May 2007 00:54:12 -0700 (PDT)
Message-ID: <20070502.005412.99176640.davem@davemloft.net>
References: <46383B00.4080605@garzik.org>
	<20070502.002426.38687430.davem@davemloft.net>
	<4638400D.5010306@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43211
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753043AbXEBHyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 03:54:13 -0400
In-Reply-To: <4638400D.5010306@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jeff@garzik.org>
Date: Wed, 02 May 2007 03:38:53 -0400

> * adding code for a situation that never occurs in the upstream kernel.

What we could do is simply have Ingo carry this bnx2 driver patch in
his -rt patch series, and then it will propagate into upstream as soon
as it matters.
