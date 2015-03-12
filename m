From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vxlan: Correct path typo in comment
Date: Wed, 11 Mar 2015 23:07:02 -0400 (EDT)
Message-ID: <20150311.230702.562275773437899757.davem@davemloft.net>
References: <1426125610-7903-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751608AbbCLDHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 23:07:05 -0400
In-Reply-To: <1426125610-7903-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Thu, 12 Mar 2015 11:00:10 +0900

> Flags are used in the return path rather than the return patch.
> 
> Fixes: af33c1adae1e ("vxlan: Eliminate dependency on UDP socket in transmit path")
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied.
