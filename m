From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/7] openvswitch: VXLAN tunneling.
Date: Sat, 27 Jul 2013 19:27:06 -0700 (PDT)
Message-ID: <20130727.192706.956748015327892413.davem@davemloft.net>
References: <1374880482-2846-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752953Ab3G1C1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jul 2013 22:27:09 -0400
In-Reply-To: <1374880482-2846-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Fri, 26 Jul 2013 16:14:42 -0700

> First three vxlan patches extends vxlan so that openvswitch 
> can share vxlan udp port with vxlan module. Rest of patches
> refactors vxlan data plane so that ovs can share that
> code with vxlan module.
> Last patch adds vxlan-vport to openvswitch.

Thanks Pravin, my concerns are addressed, I look forward to
seeing this in it's final form from Stephen et al.
