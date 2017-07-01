From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v6 00/16] bpf: Adds support for sock_ops
Date: Sat, 01 Jul 2017 16:22:52 -0700 (PDT)
Message-ID: <20170701.162252.1145335528633660329.davem@davemloft.net>
References: <20170701030255.1931076-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, bmatheny@fb.com,
        ast@fb.com, daniel@iogearbox.net, dsa@cumulusnetworks.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35086 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751976AbdGAXWz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 19:22:55 -0400
In-Reply-To: <20170701030255.1931076-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Fri, 30 Jun 2017 20:02:39 -0700

> Created a new BPF program type, BPF_PROG_TYPE_SOCK_OPS, and a corresponding
> struct that allows BPF programs of this type to access some of the
> socket's fields (such as IP addresses, ports, etc.) and setting
> connection parameters such as buffer sizes, initial window, SYN/SYN-ACK
> RTOs, etc.

Series applied, thanks Lawrence.
