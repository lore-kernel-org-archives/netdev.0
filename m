From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] l2tp: remove unused code
Date: Wed, 01 Nov 2017 10:57:46 +0900 (KST)
Message-ID: <20171101.105746.150911072675707358.davem@davemloft.net>
References: <cover.1509466904.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKAB5t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:57:49 -0400
In-Reply-To: <cover.1509466904.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Tue, 31 Oct 2017 17:36:41 +0100

> Patch #1 removes the ref/deref mechanism that was originally used to
> prevent ppp pseudowires from dropping their sockets. This mechanism
> was error prone and isn't used anymore.
> 
> Patch #2 removes some module specific refcount debugging.
> Patches #3 and #4 take care of some dead code.

Series applied, thanks.
