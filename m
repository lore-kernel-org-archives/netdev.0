From: "James R. Hay" <jrhay@haya.qc.ca>
Subject: Re: D-Link DGE-530T and r8169.c
Date: Mon, 17 Sep 2012 16:01:25 -0400 (EDT)
Message-ID: <alpine.LNX.2.00.1209171558220.13421@hay.haya.qc.ca>
References: <alpine.LNX.2.00.1209171139540.11109@hay.haya.qc.ca> <20120917174706.GA24838@electric-eye.fr.zoreil.com>
Reply-To: "James R. Hay" <jrhay@haya.qc.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail5.hay-net.net ([205.236.99.37]:60795 "EHLO
	mail4.hay-net.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756268Ab2IQUBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 16:01:40 -0400
In-Reply-To: <20120917174706.GA24838@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thank you very much.  Evidently I'm a bit further behind on the kernel 
version than I thought.

Jim.

On Mon, 17 Sep 2012, Francois Romieu wrote:

--(snip)--

>>
>> 	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4302), 0, 0, RTL_CFG_0 },
>
> The ID above was added by 93a3aa25933461d76141179fc94aa32d5f9d954a between
> v3.0 and v3.1. See:
>
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git;a=commitdiff;h=93a3aa25933461d76141179fc94aa32d5f9d954a
>
> -- 
> Ueimor
>

James R. Hay				jrhay@HayA.QC.CA
Hay-Net Networks			http://www.hay-net.net
P.O. Box 46051
Pointe Claire, QC
H9R 5R4
