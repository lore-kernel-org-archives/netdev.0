From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: uapi: use hex numbers for NLM_F_* flags
Date: Sat, 08 Apr 2017 08:26:16 -0700 (PDT)
Message-ID: <20170408.082616.616311937034774196.davem@davemloft.net>
References: <20170406141042.30309-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40716 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdDHP0S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 11:26:18 -0400
In-Reply-To: <20170406141042.30309-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu,  6 Apr 2017 16:10:42 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> It's rather confusing that the netlink message flags are
> numbered 1, 2, 4, 8, 16, 32, <unused>, 0x100. Make that
> more understandable by numbering the lower ones with hex
> constants as well.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

This is fine, applied, thanks.
