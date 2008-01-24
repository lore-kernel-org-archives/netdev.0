From: Timur Tabi <timur@freescale.com>
Subject: Re: [PATCH] UCC TDM driver for QE based MPC83xx platforms.
Date: Thu, 24 Jan 2008 09:39:59 -0600
Message-ID: <4798B14F.2020005@freescale.com>
References: <Pine.LNX.4.64.0801241014240.27491@linux121> <20080124171920.49d805cb.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Poonam_Aggrwal-b10812 <b10812@freescale.com>,
	kumar.gala@freescale.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rubini@vision.unipv.it, linuxppc-dev@ozlabs.org,
	michael.barkowski@freescale.com, rich.cutler@freescale.com,
	ashish.kalra@freescale.com
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:50922 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752515AbYAXPkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 10:40:37 -0500
In-Reply-To: <20080124171920.49d805cb.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Rothwell wrote:

>> +	tdm_ctrl[device_num]->ut_info->uf_info.tdm_tx_clk =
>> +			(char *) of_get_property(np, "fsl,tdm-tx-clk", NULL);
>                                 ^
> We don't normall put spaces here.

Since when?

-- 
Timur Tabi
Linux kernel developer at Freescale
