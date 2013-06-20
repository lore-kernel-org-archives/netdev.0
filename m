From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 00/12] openvswitch: gre tunneling support.
Date: Wed, 19 Jun 2013 18:08:21 -0700 (PDT)
Message-ID: <20130619.180821.1778396090877108077.davem@davemloft.net>
References: <1371516561-17622-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46883 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964831Ab3FTBIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 21:08:22 -0400
In-Reply-To: <1371516561-17622-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Mon, 17 Jun 2013 17:49:21 -0700

> Following patch series adds support for gre tunneling.
> First six patches extend kernel gre and ip_tunnel modules
> api so that there is more code sharing between gre modules
> and ovs. Rest of patches adds ovs tunneling infrastructre
> and gre protocol vport.
> 
> V2 fixes two patches according to comments from Jesse.

Series applied, thanks.
