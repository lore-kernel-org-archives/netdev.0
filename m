From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Remove unneeded pointer iph from ipcomp6_input() in
 net/ipv6/ipcomp6.c
Date: Wed, 05 Sep 2007 07:57:23 -0700 (PDT)
Message-ID: <20070905.075723.104052614.davem@davemloft.net>
References: <46DE4248.6070604@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: micah.gruber@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:54314
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752137AbXIEPUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2007 11:20:46 -0400
In-Reply-To: <46DE4248.6070604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Micah Gruber <micah.gruber@gmail.com>
Date: Wed, 05 Sep 2007 13:44:40 +0800

> This trivial patch removes the unneeded pointer iph, which is never used.
> 
> Signed-off-by: Micah Gruber < micah.gruber@gmail.com>

Applied, thanks.
