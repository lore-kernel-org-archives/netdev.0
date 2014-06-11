From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: filter: fix nlattr and nlattr_nest BPF
 tests
Date: Wed, 11 Jun 2014 00:13:44 -0700 (PDT)
Message-ID: <20140611.001344.776198810644049157.davem@davemloft.net>
References: <1402102100-30215-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755378AbaFKHNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 03:13:44 -0400
In-Reply-To: <1402102100-30215-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri,  6 Jun 2014 17:48:20 -0700

> - 'struct nlattr' must be 2 byte aligned
> - provide big-endian input data for nlattr/nlattr_nest tests
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied.
