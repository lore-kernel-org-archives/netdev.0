From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: fix PPP pseudo-wire auto-loading
Date: Tue, 04 Apr 2017 10:28:18 -0700 (PDT)
Message-ID: <20170404.102818.806099917141387427.davem@davemloft.net>
References: <4f0c437337252f267de92ae650cb39e48dbff192.1491218507.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com,
        stephen@networkplumber.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60796 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753254AbdDDR2V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 13:28:21 -0400
In-Reply-To: <4f0c437337252f267de92ae650cb39e48dbff192.1491218507.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Mon, 3 Apr 2017 13:23:15 +0200

> PPP pseudo-wire type is 7 (11 is L2TP_PWTYPE_IP).
> 
> Fixes: f1f39f911027 ("l2tp: auto load type modules")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable.
