From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Sun, 29 Nov 2015 22:21:38 -0500 (EST)
Message-ID: <20151129.222138.1582847465760563254.davem@davemloft.net>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
	<1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
	<CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anjali.singhai@intel.com, netdev@vger.kernel.org, jesse@kernel.org,
	kiran.patil@intel.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbbK3DVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2015 22:21:40 -0500
In-Reply-To: <CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 23 Nov 2015 13:53:44 -0800

> The bad effect of this model is that it is encourages HW vendors to
> continue implement HW protocol specific support for encapsulations, we
> get so much more benefit if they implement protocol generic
> mechanisms.

+1
