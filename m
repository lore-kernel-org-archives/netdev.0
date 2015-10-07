From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 0/2] openvswitch: add IPv6 tunneling support
Date: Wed, 07 Oct 2015 04:18:29 -0700 (PDT)
Message-ID: <20151007.041829.478887127666584497.davem@davemloft.net>
References: <cover.1444041801.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, pshelar@nicira.com,
	jesse@nicira.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752134AbbJGLCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 07:02:45 -0400
In-Reply-To: <cover.1444041801.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Mon,  5 Oct 2015 13:09:45 +0200

> This builds on the previous work that added IPv6 support to lwtunnels and
> adds IPv6 tunneling support to ovs.
> 
> To use IPv6 tunneling, there needs to be a metadata based tunnel net_device
> created and added to the ovs bridge. Currently, only vxlan is supported by
> the kernel, with geneve to follow shortly. There's no need nor intent to add
> a support for this into the vport-vxlan (etc.) compat layer.
> ---
> 
> v3: dropped the last two patches added in v2.

Series applied, thanks.
