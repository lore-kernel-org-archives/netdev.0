From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tools: bpf_asm: cleanup vlan extension
 related token
Date: Tue, 24 Mar 2015 21:21:54 -0400 (EDT)
Message-ID: <20150324.212154.1957494135620684311.davem@davemloft.net>
References: <40b0db160a8e130431d2bb3de10089baf02bb3a1.1427230878.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41113 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589AbbCYBV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 21:21:56 -0400
In-Reply-To: <40b0db160a8e130431d2bb3de10089baf02bb3a1.1427230878.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Tue, 24 Mar 2015 23:19:24 +0100

> We now have K_VLANT, K_VLANP and K_VLANTPID. Clean them up into more
> descriptive token, namely K_VLAN_TCI, K_VLAN_AVAIL and K_VLAN_TPID.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
