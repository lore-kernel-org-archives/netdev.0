From: David Miller <davem@davemloft.net>
Subject: Re: [NET_SCHED 01/04]: em_meta: fix compile warning
Date: Tue, 05 Feb 2008 16:19:42 -0800 (PST)
Message-ID: <20080205.161942.229499602.davem@davemloft.net>
References: <20080205142902.13543.88604.sendpatchset@localhost.localdomain>
	<20080205142903.13543.6864.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760060AbYBFATN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 19:19:13 -0500
In-Reply-To: <20080205142903.13543.6864.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  5 Feb 2008 15:29:40 +0100 (MET)

> [NET_SCHED]: em_meta: fix compile warning
> 
> net/sched/em_meta.c: In function 'meta_int_vlan_tag':
> net/sched/em_meta.c:179: warning: 'tag' may be used uninitialized in this function
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
