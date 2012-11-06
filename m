From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sparc: bpf_jit_comp: add VLAN instructions
 for BPF JIT
Date: Tue, 06 Nov 2012 18:33:04 -0500 (EST)
Message-ID: <20121106.183304.247782713765794241.davem@davemloft.net>
References: <20121105025930.GA5197@thinkbox>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dxchgb@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947Ab2KFXdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 18:33:08 -0500
In-Reply-To: <20121105025930.GA5197@thinkbox>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dxchgb@gmail.com>
Date: Mon, 5 Nov 2012 03:59:30 +0100

> This patch is a follow-up for patch "net: filter: add vlan tag access"
> to support the new VLAN_TAG/VLAN_TAG_PRESENT accessors in BPF JIT.
> 
> Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
> ---
>  Disclaimer: uncompiled and untested, since I don't have a SPARC machine,
>  but it should (hopefully) integrate cleanly. ;)

Looks good, applied, thanks Dan.
