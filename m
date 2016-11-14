From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/6] bpf: LRU map
Date: Mon, 14 Nov 2016 13:19:16 -0500 (EST)
Message-ID: <20161114.131916.1145168392517998076.davem@davemloft.net>
References: <1478890511-1346984-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38360 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754085AbcKNSTS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 13:19:18 -0500
In-Reply-To: <1478890511-1346984-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 11 Nov 2016 10:55:05 -0800

> This patch set adds LRU map implementation to the existing BPF map
> family.

Alexei and Daniel, can I please get some review of this series?

Thank you.
