From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] s390/bpf: implement bpf_tail_call JIT
 support
Date: Sun, 31 May 2015 21:39:31 -0700 (PDT)
Message-ID: <20150531.213931.282168647572228489.davem@davemloft.net>
References: <1433007731-16992-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: holzheu@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45350 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804AbbFAEjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 00:39:33 -0400
In-Reply-To: <1433007731-16992-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Sat, 30 May 2015 10:42:08 -0700

> This set is for net-next tree.
> 
> Patch 3 adds bpf_tail_call() support for s390x JIT. It has
> a dependency on patches 1 and 2 that will also be submitted
> to stable via Martin Schwidefsky.

In this kind of scenerio, patches #1 and #2 should go via my
tree (somehow), and then when I next merge 'net' into 'net-next'
you can submit patch #3.
