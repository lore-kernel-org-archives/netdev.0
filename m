From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Move to BPF selftests
Date: Tue, 18 Oct 2016 11:36:12 -0400 (EDT)
Message-ID: <20161018.113612.2148099210449625187.davem@davemloft.net>
References: <cover.1476705709.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935596AbcJRPgO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 11:36:14 -0400
In-Reply-To: <cover.1476705709.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 17 Oct 2016 14:28:34 +0200

> This set improves the test_verifier and test_maps suite and moves
> it over to a new BPF selftest directory, so we can keep improving
> it under kernel selftest umbrella. This also integrates a test
> script for checking test_bpf.ko under various JIT options.

Series applied, thanks Daniel.
