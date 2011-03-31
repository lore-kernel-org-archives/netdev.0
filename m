From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-rhine: trivial sparse annotation in vlan_tci helper
Date: Wed, 30 Mar 2011 21:43:30 -0700 (PDT)
Message-ID: <20110330.214330.216754430.davem@davemloft.net>
References: <1301368139-2489-1-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47554
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753376Ab1CaEoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 00:44:07 -0400
In-Reply-To: <1301368139-2489-1-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Mon, 28 Mar 2011 20:08:59 -0700

> Noticed by sparse:
> drivers/net/via-rhine.c:1706:16: warning: cast to restricted __be16
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.
