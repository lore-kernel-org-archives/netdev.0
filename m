From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/8] Introduce bpf ID
Date: Tue, 06 Jun 2017 15:41:48 -0400 (EDT)
Message-ID: <20170606.154148.70945478544961796.davem@davemloft.net>
References: <cover.1496686606.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37556 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751445AbdFFTlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 15:41:50 -0400
In-Reply-To: <cover.1496686606.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 5 Jun 2017 12:15:45 -0700

> This patch series:
> 1) Introduce ID for both bpf_prog and bpf_map.
> 2) Add bpf commands to iterate the prog IDs and map
>    IDs of the system.
> 3) Add bpf commands to get a prog/map fd from an ID
> 4) Add bpf command to get prog/map info from a fd.
>    The prog/map info is a jump start in this patchset
>    and it is not meant to be a complete list.  They can
>    be extended in the future patches.

Looks good, series applied, thanks Martin.
