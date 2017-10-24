From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/6] add a set of tracepoints to tcp stack
Date: Tue, 24 Oct 2017 01:25:45 +0100 (WEST)
Message-ID: <20171024.012545.410359186828074795.davem@davemloft.net>
References: <20171023162027.2880430-1-songliubraving@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        liu.song.a23@gmail.com
To: songliubraving@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdJXAZs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 20:25:48 -0400
In-Reply-To: <20171023162027.2880430-1-songliubraving@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Song Liu <songliubraving@fb.com>
Date: Mon, 23 Oct 2017 09:20:21 -0700

> Changes from v1:
> 
> Fix build error (with ipv6 as ko) by adding EXPORT_TRACEPOINT_SYMBOL_GPL
> for trace_tcp_send_reset.

Series applied.
