From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] BPF support for flow labels
Date: Fri, 11 Mar 2016 15:14:55 -0500 (EST)
Message-ID: <20160311.151455.1944443062552087805.davem@davemloft.net>
References: <cover.1457488298.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbcCKUO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 15:14:58 -0500
In-Reply-To: <cover.1457488298.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed,  9 Mar 2016 03:00:01 +0100

> This set adds support for tunnel key flow labels for vxlan
> and geneve devices in collect meta data mode and eBPF support
> for managing these. For details please see individual patches.

Series applied, although I agree with the calls for more consolidation.

Thanks.
