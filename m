From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] BPF range marking improvements for meta
 data
Date: Thu, 02 Nov 2017 17:02:07 +0900 (KST)
Message-ID: <20171102.170207.535205104039169423.davem@davemloft.net>
References: <cover.1509576758.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, john.r.fastabend@gmail.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45052 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755700AbdKBICN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:02:13 -0400
In-Reply-To: <cover.1509576758.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  1 Nov 2017 23:58:08 +0100

> The set contains improvements for direct packet access range
> markings related to data_meta pointer and test cases for all
> such access patterns that the verifier matches on.

Series applied.

Thanks, in particular, for following up with the merge
cleanups.
