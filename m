From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7 2.6.28] cxgb3 - reset the adapter on fatal error
Date: Wed, 08 Oct 2008 17:40:50 -0700 (PDT)
Message-ID: <20081008.174050.183370451.davem@davemloft.net>
References: <20081009003356.13282.25797.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32843
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754371AbYJIAlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 20:41:15 -0400
In-Reply-To: <20081009003356.13282.25797.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Wed, 08 Oct 2008 17:33:57 -0700

> when a fatal error occurs, bring ports down, reset the chip,
> and bring ports back up.
> 
> Factorize code used for both EEH and fatal error recovery.
> Fix timer usage when bringing up/resetting sge queue sets.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

Applied.
