From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] openvswitch: Allow GRE ports when
 compiled as a module.
Date: Mon, 24 Jun 2013 00:19:10 -0700 (PDT)
Message-ID: <20130624.001910.1218514334753141990.davem@davemloft.net>
References: <1371856631-47807-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@nicira.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752310Ab3FXHTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 03:19:10 -0400
In-Reply-To: <1371856631-47807-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 21 Jun 2013 16:17:10 -0700

> Open vSwitch GRE tunnels are currently only enabled if the GRE
> datapath code is statically compiled in but it should be possible
> to use it as a module as well.
> 
> CC: Pravin Shelar <pshelar@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Pravin's copy of this same exact patch hit my inbox first, so I applied
his.  Thanks.
