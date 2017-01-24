From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: free ip_vs_dest structs when refcnt=0
Date: Tue, 24 Jan 2017 16:17:04 -0500 (EST)
Message-ID: <20170124.161704.2301857219275083413.davem@davemloft.net>
References: <1485262100-12366-1-git-send-email-dwindsor@gmail.com>
        <alpine.LFD.2.11.1701242255570.2743@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dwindsor@gmail.com, netdev@vger.kernel.org,
        kernel-hardening@lists.openwall.com, keescook@chromium.org,
        elena.reshetova@intel.com, ishkamiel@gmail.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751018AbdAXVRF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 16:17:05 -0500
In-Reply-To: <alpine.LFD.2.11.1701242255570.2743@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Tue, 24 Jan 2017 23:14:29 +0200 (EET)

> 	The changes look ok to me but as this is a net-next
> material I also prefer some comments in the code to be updated:

It also needs to be posted to netfilter-devel with the IPVS maintainer
CC:'d
