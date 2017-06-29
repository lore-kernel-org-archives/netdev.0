From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bpf: Add syscall lookup support for fd
 array and htab
Date: Thu, 29 Jun 2017 14:04:45 -0400 (EDT)
Message-ID: <20170629.140445.1290828010529506955.davem@davemloft.net>
References: <20170628060835.2142549-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@fb.com,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43798 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751936AbdF2SEu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 14:04:50 -0400
In-Reply-To: <20170628060835.2142549-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 27 Jun 2017 23:08:33 -0700

> This patchset adds BPF_MAP_LOOKUP_ELEM syscall support for
> BPF_MAP_TYPE_PROG_ARRAY,
> BPF_MAP_TYPE_ARRAY_OF_MAPS and
> BPF_MAP_TYPE_HASH_OF_MAPS

Series applied, thanks.
