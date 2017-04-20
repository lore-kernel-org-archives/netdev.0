From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: remove reference to sock_filter_ext from
 kerneldoc comment
Date: Thu, 20 Apr 2017 15:27:14 -0400 (EDT)
Message-ID: <20170420.152714.1304312782017597722.davem@davemloft.net>
References: <20170418092700.9157-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@fb.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947026AbdDTT1R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:27:17 -0400
In-Reply-To: <20170418092700.9157-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 18 Apr 2017 11:27:00 +0200

> struct sock_filter_ext didn't make it into the tree and is now called
> struct bpf_insn. Reword the kerneldoc comment for bpf_convert_filter()
> accordingly.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thank you.
