From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] Introduce bpf ID
Date: Wed, 31 May 2017 14:30:16 -0400 (EDT)
Message-ID: <20170531.143016.582261847755991960.davem@davemloft.net>
References: <cover.1496189155.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42288 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750999AbdEaSaS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:30:18 -0400
In-Reply-To: <cover.1496189155.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Tue, 30 May 2017 17:08:29 -0700

> This patch series:
> 1) Introduce ID for both bpf_prog and bpf_map.
> 2) Add bpf commands to iterate the prog IDs and map
>    IDs of the system.
> 3) Add bpf commands to get a prog/map fd from an ID
> 4) Add bpf command to get prog/map info from a fd.
>    The prog/map info is a jump start in this patchset
>    and it is not meant to be a complete list.  They can
>    be extended in the future patches.

This needs a respin to address the kbuild bot build failures.
