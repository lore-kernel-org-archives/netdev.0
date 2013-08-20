From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 0/8] openvswitch: VXLAN tunneling.
Date: Tue, 20 Aug 2013 00:17:12 -0700 (PDT)
Message-ID: <20130820.001712.1951982778222810447.davem@davemloft.net>
References: <1376936559-25427-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36678 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238Ab3HTHRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 03:17:13 -0400
In-Reply-To: <1376936559-25427-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Mon, 19 Aug 2013 11:22:39 -0700

> First four vxlan patches extends vxlan so that openvswitch
> can share vxlan recv code. Rest of patches refactors vxlan
> data plane so that ovs can share that code with vxlan module.
> Last patch adds vxlan-vport to openvswitch.
> 
> v7 fixed first patch as suggested by Stephen Hemminger.
> v6 series splits second patch into two and has few style fixes.
> v5 series disallow any udp port sharing between
> kernel-vxlan and ovs-vxlan as suggested by Stephen Hemminger.

Series applied, thanks.
