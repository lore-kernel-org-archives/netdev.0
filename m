From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/6] bpf: show bpf programs
Date: Thu, 27 Apr 2017 12:40:46 -0400 (EDT)
Message-ID: <20170427.124046.1086864083296497668.davem@davemloft.net>
References: <5b1f23e3-86a7-69aa-91e2-1dc72125f22b@stressinduktion.org>
        <20170427.120019.1559603500876505216.davem@davemloft.net>
        <d99407db-895c-01c0-8e26-c6bd2b79d4ff@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.com, jbenc@redhat.com, aconole@bytheb.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42876 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdD0Qks (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 12:40:48 -0400
In-Reply-To: <d99407db-895c-01c0-8e26-c6bd2b79d4ff@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 27 Apr 2017 18:28:17 +0200

> Merely I tried to establish the procfs interface as quick look
> interface

Show me that "quick look" nftables dumping facility via procfs
and I'll start to listen to you.

What you are proposing has no real value once we have bpf() system
call based traversal and has no strict precedence across the
networking subsystem.

Thank you.
