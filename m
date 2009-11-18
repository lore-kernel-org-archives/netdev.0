From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibm_newemac: Fix EMACx_TRTR[TRT] bit shifts
Date: Wed, 18 Nov 2009 05:11:29 -0800 (PST)
Message-ID: <20091118.051129.154107560.davem@davemloft.net>
References: <1258505815-31261-1-git-send-email-dmitchell@appliedmicro.com>
	<200911181107.51661.sr@denx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@lists.ozlabs.org, dmitchell@appliedmicro.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	benh@kernel.crashing.org
To: sr@denx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40083
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751690AbZKRNLM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 08:11:12 -0500
In-Reply-To: <200911181107.51661.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Roese <sr@denx.de>
Date: Wed, 18 Nov 2009 11:07:51 +0100

> On Wednesday 18 November 2009 01:56:55 Dave Mitchell wrote:
>> The TRT bit shifts were reversed for EMAC4 and non-EMAC4 during the
>> port from ibm_emac to ibm_newemac. This patch corrects that error.
>> 
>> Signed-off-by: Dave Mitchell <dmitchell@appliedmicro.com>
>> Acked-by: Feng Kan <fkan@appliedmicro.com>
>> Acked-by: Prodyut Hazarika <phazarika@appliedmicro.com>
> 
> Acked-by: Stefan Roese <sr@denx.de>
> 
> Would be great if this could go into 2.6.32. Thanks.

Applied to net-2.6, thanks.
