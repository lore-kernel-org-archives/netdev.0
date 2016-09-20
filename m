From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 net-next 00/15] BPF hardware offload (cls_bpf for now)
Date: Mon, 19 Sep 2016 22:08:43 -0400 (EDT)
Message-ID: <20160919.220843.635571868095404829.davem@davemloft.net>
References: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41042 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932282AbcITCIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 22:08:46 -0400
In-Reply-To: <1474211365-20088-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Sun, 18 Sep 2016 16:09:10 +0100

> As spotted by Daniel JIT might have accessed indexes past the end
> of verifier's reg_state array.

This series doesn't apply cleanly to net-next, please respin.

Thanks.
