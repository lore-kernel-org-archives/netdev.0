From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: force bridge module(s) to be GPL
Date: Fri, 11 Sep 2009 11:50:15 -0700 (PDT)
Message-ID: <20090911.115015.111772936.davem@davemloft.net>
References: <20090910145146.3ee30338@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54044
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755951AbZIKSt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 14:49:59 -0400
In-Reply-To: <20090910145146.3ee30338@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 10 Sep 2009 14:51:46 -0700

> The only valid usage for the bridge frame hooks are by a
> GPL components (such as the bridge module).
> The kernel should not leave a crack in the door for proprietary
> networking stacks to slip in.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
