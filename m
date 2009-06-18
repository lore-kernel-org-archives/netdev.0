From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/9] sky2: receive counter update
Date: Wed, 17 Jun 2009 18:51:01 -0700 (PDT)
Message-ID: <20090617.185101.147556624.davem@davemloft.net>
References: <20090617173031.703636683@vyatta.com>
	<20090617173139.956656294@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51055
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753202AbZFRBu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2009 21:50:57 -0400
In-Reply-To: <20090617173139.956656294@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 17 Jun 2009 10:30:36 -0700

> Since it is likely that there are multiple packets received per
> interrupt, only update the receive counters once after all
> packets are processed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
