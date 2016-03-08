From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] BPF updates
Date: Tue, 08 Mar 2016 14:05:41 -0500 (EST)
Message-ID: <20160308.140541.1909427706737952589.davem@davemloft.net>
References: <cover.1457099834.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbcCHTFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 14:05:46 -0500
In-Reply-To: <cover.1457099834.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  4 Mar 2016 15:15:01 +0100

> Couple of misc updates to BPF, besides others this series adds
> bpf_csum_diff() to be used with L3 csums, allows for managing
> tunnel options for collect meta data mode, and enabling ipv6
> traffic class for collect meta data in vxlan specifically (geneve
> already supports it). For more details, please see individual
> patches.
> 
> The series requires net to be merged into net-next first to
> avoid any further pending merge conflicts.

Ok, I just merged net into net-next and therefore was able to apply
this series, thanks Daniel.
