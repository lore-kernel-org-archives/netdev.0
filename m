From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Further robustify putting BPF progs
Date: Fri, 01 Jul 2016 16:05:17 -0400 (EDT)
Message-ID: <20160701.160517.1883958453142988302.davem@davemloft.net>
References: <cover.1467298256.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, jannh@google.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42765 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589AbcGAUFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 16:05:25 -0400
In-Reply-To: <cover.1467298256.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 30 Jun 2016 17:24:42 +0200

> This series addresses a potential issue reported to us by Jann Horn
> with regards to putting progs. First patch moves progs generally under
> RCU destruction and second patch refactors getting of progs to simplify
> code a bit. For details, please see individual patches. Note, we think
> that addressing this one in net-next should be sufficient.

Series applied, thanks Daniel.
