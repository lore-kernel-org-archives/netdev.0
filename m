From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Netfilter/IPVS fixes for net
Date: Tue, 07 Jun 2016 17:14:26 -0700 (PDT)
Message-ID: <20160607.171426.1162562691220395952.davem@davemloft.net>
References: <1465252697-1986-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59263 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893AbcFHAO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 20:14:27 -0400
In-Reply-To: <1465252697-1986-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue,  7 Jun 2016 00:38:15 +0200

> The following patchset contains two Netfilter/IPVS fixes for your net
> tree, they are:
> 
> 1) Fix missing alignment in next offset calculation for standard
>    targets, introduced in the previous merge window, patch from
>    Florian Westphal.
> 
> 2) Fix to correct the handling of outgoing connections which use the
>    SIP-pe such that the binding of a real-server is updated when needed.
>    This was an omission from changes introduced by Marco Angaroni in
>    the previous merge window too, to allow handling of outgoing
>    connections by the SIP-pe. Patch and report came via Simon Horman.

Pulled, thanks Pablo.
