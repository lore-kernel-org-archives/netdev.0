From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: report right mtu value in error message
Date: Mon, 17 Oct 2016 13:15:45 -0400 (EDT)
Message-ID: <20161017.131545.863029198846136458.davem@davemloft.net>
References: <1476723742-7557-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jarod@redhat.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58090 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932489AbcJQRPq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 13:15:46 -0400
In-Reply-To: <1476723742-7557-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Mon, 17 Oct 2016 18:02:22 +0100

> Check is for max_mtu but message reports min_mtu.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Good catch, applied, thanks.
