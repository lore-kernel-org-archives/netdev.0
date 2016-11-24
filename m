From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] samples/bpf: fix bpf loader
Date: Thu, 24 Nov 2016 16:05:09 -0500 (EST)
Message-ID: <20161124.160509.1361530663050535399.davem@davemloft.net>
References: <1479862329-2361912-1-git-send-email-ast@fb.com>
        <1479862329-2361912-2-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41724 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965980AbcKXVFR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 16:05:17 -0500
In-Reply-To: <1479862329-2361912-2-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Tue, 22 Nov 2016 16:52:09 -0800

> llvm can emit relocations into sections other than program code
> (like debug info sections). Ignore them during parsing of elf file
> 
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>

Applied.
