From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] bridge: make bridge address settings sticky
Date: Tue, 17 Jun 2008 16:11:25 -0700 (PDT)
Message-ID: <20080617.161125.264901522.davem@davemloft.net>
References: <20080617165211.615620784@vyatta.com>
	<20080617165223.184830407@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34691
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762112AbYFQXLZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:11:25 -0400
In-Reply-To: <20080617165223.184830407@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 17 Jun 2008 09:52:13 -0700

> Normally, the bridge just chooses the smallest mac address as the
> bridge id and mac address of bridge device. But if the administrator
> has explictly set the interface address then don't change it.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
