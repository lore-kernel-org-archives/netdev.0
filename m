From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 4/4] MPC85xx: Add UCC6 and UCC8 nodes in SGMII mode for MPC8569MDS
Date: Wed, 10 Jun 2009 20:35:59 -0500
Message-ID: <8BE7FB34-A682-4E6D-B3AC-45D5594812C8@kernel.crashing.org>
References: <1243951456-4685-2-git-send-email-Haiying.Wang@freescale.com> <1243951456-4685-3-git-send-email-Haiying.Wang@freescale.com> <1243951456-4685-4-git-send-email-Haiying.Wang@freescale.com> <20090603.035132.157926180.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Haiying.Wang@freescale.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:58595 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752753AbZFKBiJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2009 21:38:09 -0400
In-Reply-To: <20090603.035132.157926180.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 3, 2009, at 5:51 AM, David Miller wrote:

> From: Haiying Wang <Haiying.Wang@freescale.com>
> Date: Tue,  2 Jun 2009 10:04:16 -0400
>
>> Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
>
> I couldn't apply this to net-next-2.6 because this DTS
> file being patched doesn't exist there.
>
> Perhaps the powerpc-next tree can suck it in...

I'll pick this one up and send it via the powerpc tree.

- k
