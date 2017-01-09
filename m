From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] sh_eth: "intgelligent checksum" related cleanups
Date: Mon, 09 Jan 2017 15:41:13 -0500 (EST)
Message-ID: <20170109.154113.2146756234032501412.davem@davemloft.net>
References: <2397522.NNiHGddh8y@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50210 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S940688AbdAIUlO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:41:14 -0500
In-Reply-To: <2397522.NNiHGddh8y@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sat, 07 Jan 2017 00:01:40 +0300

>    Here's a set of 2 patches against DaveM's 'net.git' repo, as they are based
> on a couple patches merged there recently; however, the patches are destined
> for 'net-next.git' (once 'net.git' gets merged there next time). I'm cleaning
> up the "intelligent checksum" related code (however, the driver only disables
> this feature for now, theres's no proper offload supprt yet).

Series applied to net-next, thanks.
