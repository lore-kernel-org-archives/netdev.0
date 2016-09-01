From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sky2: use napi_complete_done
Date: Thu, 01 Sep 2016 14:10:12 -0700 (PDT)
Message-ID: <20160901.141012.384977696986388530.davem@davemloft.net>
References: <20160829101637.4f0663e5@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mlindner@marvell.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38848 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756039AbcIAVKN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 17:10:13 -0400
In-Reply-To: <20160829101637.4f0663e5@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 29 Aug 2016 10:16:37 -0700

> Update the sky2 driver to pass number of packets done to NAPI.
> The driver was never updated when napi_complete_done was added.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied, thanks Stephen.
