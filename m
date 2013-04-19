From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter fixes for net
Date: Fri, 19 Apr 2013 14:25:24 -0400 (EDT)
Message-ID: <20130419.142524.355513268269195553.davem@davemloft.net>
References: <1366334162-4958-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590Ab3DSSZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 14:25:27 -0400
In-Reply-To: <1366334162-4958-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 19 Apr 2013 03:16:00 +0200

> If time allows, please consider pulling the following patchset contains two
> late Netfilter fixes, they are:
> 
> * Skip broadcast/multicast locally generated traffic in the rpfilter,
>   (closes netfilter bugzilla #814), from Florian Westphal.
> 
> * Fix missing elements in the listing of ipset bitmap ip,mac set
>   type with timeout support enabled, from Jozsef Kadlecsik.
> 
> The following changes since commit c2d421e171868586939c328dfb91bab840fe4c49:
> 
>   netfilter: nf_nat: fix race when unloading protocol modules (2013-04-12 11:46:31 +0200)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks Pablo.
