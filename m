From: David Miller <davem@davemloft.net>
Subject: Re: bpf_test_finish()
Date: Tue, 02 May 2017 11:14:46 -0400 (EDT)
Message-ID: <20170502.111446.158985224098905903.davem@davemloft.net>
References: <20170501.235610.564976046138352257.davem@davemloft.net>
        <a7f18cfe-049c-d580-8c15-5d09b6860c48@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49716 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750763AbdEBPOs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:14:48 -0400
In-Reply-To: <a7f18cfe-049c-d580-8c15-5d09b6860c48@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 1 May 2017 21:46:07 -0700

> I'll send a patch first thing tomorrow unless Daniel beats me to it.
> We have kattr there as well which has the whole bpf_attr copied into
> kernel memory already. Should have taken data_out from there and
> passed into bpf_test_finish().

I happen to be hacking on this file for another reason right now so
I'll work on a fix for this.  So don't worry about it.
