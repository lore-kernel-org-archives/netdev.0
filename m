From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4 0/2] napi fixes
Date: Thu, 12 Dec 2013 13:35:50 -0500 (EST)
Message-ID: <20131212.133550.1870000915443489329.davem@davemloft.net>
References: <1386759436-46737-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872Ab3LLSfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 13:35:53 -0500
In-Reply-To: <1386759436-46737-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Wed, 11 Dec 2013 10:57:14 +0000

> This 2 patch series is essentially v4 of "xen-netback: fix abuse of napi
> budget".
> 
> v4:
> - Add missing 'Reported-by' to patch 2 comment
> - Add explanation of where the ring event pointer is update to patch 2
>   comment
> 
> v3:
> - Break into two patches
> - Don't lose the work_to_do value in xenvif_build_tx_gops
> 
> v2:
> - More elaborate description of the problem and the fix in the comment.
> - Modified the check in xenvif_build_tx_gops.

These look fine to me, applied, thanks.
