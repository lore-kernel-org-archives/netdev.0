From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] Misc BPF updates
Date: Sat, 10 Jun 2017 19:06:03 -0400 (EDT)
Message-ID: <20170610.190603.1664425689165017051.davem@davemloft.net>
References: <cover.1497133948.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37782 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751633AbdFJXGF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2017 19:06:05 -0400
In-Reply-To: <cover.1497133948.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun, 11 Jun 2017 00:50:39 +0200

> This set contains a couple of misc updates: stack usage reduction
> for perf_sample_data in tracing progs, reduction of stale data in
> verifier on register state transitions that I still had in my queue
> and few selftest improvements as well as bpf_set_hash() helper for
> tc programs.

Series applied, thanks Daniel.
