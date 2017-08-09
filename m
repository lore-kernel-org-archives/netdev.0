From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests: bpf: add a test for XDP redirect
Date: Tue, 08 Aug 2017 18:13:17 -0700 (PDT)
Message-ID: <20170808.181317.478724717615134367.davem@davemloft.net>
References: <1502136882-40204-1-git-send-email-u9012063@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        john.fastabend@gmail.com
To: u9012063@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58400 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752461AbdHIBNR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 21:13:17 -0400
In-Reply-To: <1502136882-40204-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Tu <u9012063@gmail.com>
Date: Mon,  7 Aug 2017 13:14:42 -0700

> Add test for xdp_redirect by creating two namespaces with two
> veth peers, then forward packets in-between.
> 
> Signed-off-by: William Tu <u9012063@gmail.com>

Applied, thank you.
