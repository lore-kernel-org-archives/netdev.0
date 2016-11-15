From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next v3 0/7] vxlan: xmit improvements.
Date: Tue, 15 Nov 2016 12:16:28 -0500 (EST)
Message-ID: <20161115.121628.630754123263265410.davem@redhat.com>
References: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@ovn.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50470 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750890AbcKORQb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Nov 2016 12:16:31 -0500
In-Reply-To: <1479098638-4921-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@ovn.org>
Date: Sun, 13 Nov 2016 20:43:51 -0800

> Following patch series improves vxlan fast path, removes
> duplicate code and simplifies vxlan xmit code path.
> 
> v2-v3:
> Removed unrelated warning fix from patch 2.
> rearranged error handling from patch 3
> Fixed stats updates in vxlan route lookup in patch 4
> 
> v1-v2:
> Fix compilation error when IPv6 support is not enabled.

Series applied, thanks.
