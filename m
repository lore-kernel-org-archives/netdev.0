From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Make IP 'forwarding' doc more precise
Date: Sun, 12 Mar 2017 23:29:01 -0700 (PDT)
Message-ID: <20170312.232901.1815831214938759086.davem@davemloft.net>
References: <1489148697-5529-1-git-send-email-neil@tigera.io>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: neil@tigera.io
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53690 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdCMG3D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:29:03 -0400
In-Reply-To: <1489148697-5529-1-git-send-email-neil@tigera.io>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Jerram <neil@tigera.io>
Date: Fri, 10 Mar 2017 12:24:57 +0000

> It wasn't clear if the 'forwarding' setting needs to be enabled on the
> interface that packets are received from, or on the interface that
> packets are forwarded to, or both.
> 
> In fact (according to my code reading) the setting is relevant on the
> interface that packets are received from, so this change updates the doc
> to say that.
> 
> Signed-off-by: Neil Jerram <neil@tigera.io>

Applied.
