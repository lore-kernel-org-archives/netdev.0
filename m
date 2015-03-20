From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] act_bpf update
Date: Fri, 20 Mar 2015 16:22:52 -0400 (EDT)
Message-ID: <20150320.162252.977628965847070194.davem@davemloft.net>
References: <cover.1426859241.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, ast@plumgrid.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38149 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150AbbCTUWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 16:22:54 -0400
In-Reply-To: <cover.1426859241.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 20 Mar 2015 15:11:10 +0100

> This set adds native eBPF support also to act_bpf and thus covers tc
> with eBPF in the classifier *and* action part.
> 
> A link to iproute2 preview has been provided in patch 2 and the code
> will be pushed out after Stephen has processed the classifier part
> and helper bits for tc.
> 
> This set depends on ced585c83b27 ("act_bpf: allow non-default TC_ACT
> opcodes as BPF exec outcome"), so a net into net-next merge would be
> required first. Hope that's fine by you, Dave. ;)
> 
> Thanks a lot!

Even with that commit, which is in net-next now, this series does
not apply without rejects.

Please respin.
