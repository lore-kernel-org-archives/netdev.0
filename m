From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlabel: add CALIPSO to the list of built-in protocols
Date: Fri, 06 Jan 2017 22:21:03 -0500 (EST)
Message-ID: <20170106.222103.1648779014808091009.davem@davemloft.net>
References: <148373081425.18818.6670627192248645738.stgit@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51862 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752126AbdAGDVF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 22:21:05 -0500
In-Reply-To: <148373081425.18818.6670627192248645738.stgit@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Fri, 06 Jan 2017 14:26:54 -0500

> From: Paul Moore <paul@paul-moore.com>
> 
> When we added CALIPSO support in Linux v4.8 we forgot to add it to the
> list of supported protocols with display at boot.
> 
> Signed-off-by: Paul Moore <paul@paul-moore.com>

Applied.
