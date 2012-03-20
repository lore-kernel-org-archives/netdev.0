From: Sujith Manoharan <c_manoha@qca.qualcomm.com>
Subject: Re: ath: DMA failed to stop in 10 ms AR_CR=0x00000024 AR_DIAG_SW=0x02000020 DMADBG_7=0x00008040
Date: Tue, 20 Mar 2012 20:52:43 +0530
Message-ID: <20328.41155.468698.30887@gargle.gargle.HOWL>
References: <4F576FD5.2050208@gmail.com>
	<CAD2nsn23UqshHz1ZUn8bHN0rWyOMbBHhn9V8pmCc4_aT_uGYaw@mail.gmail.com>
	<4F577D9B.7020402@gmail.com>
	<4F579A88.6030503@openwrt.org>
	<4F61F551.5010608@gmail.com>
	<4F639851.5080500@gmail.com>
	<4F674616.8080103@gmail.com>
	<CAD2nsn3xpkGenrK50YmE5D7Odg3sBEek5zKcLZF6MAm69p5RJg@mail.gmail.com>
	<4F674FF5.2060406@gmail.com>
	<4F6751B2.1030809@openwrt.org>
	<4F681B78.9000207@gmail.com>
	<CAD2nsn0d-3edYGH8u+v5mhrUZBMsznDNRDkDHE-tErG8uGk84Q@mail.gmail.com>
	<4F68235C.5090701@gmail.com>
	<CAD2nsn0toAjyWw48J7oREES0=x6D72hMntP+WpAjHmR5drd-tQ@mail.gmail.com>
	<4F682555.3020502@gmail.com>
	<20328.16366.166909.255035@gargle.gargle.HOWL>
	<4F6891F1.9010105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mohammed Shafi <shafi.wireless@gmail.com>,
	Linux-wireless <linux-wireless@vger.kernel.org>,
	Felix Fietkau <nbd@openwrt.org>,
	<linux-kernel@vger.kernel.org>,
	Linux-netdev <netdev@vger.kernel.org>
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:15489 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760576Ab2CTPX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2012 11:23:29 -0400
In-Reply-To: <4F6891F1.9010105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Justin P. Mattock wrote:
> both mohammed and sujith Thank you for the patches for this issue!
> I really appreciate this..
> 
> I went and applied the debug printk and added ath_node_attach as well to 
> my linux-next clone, will run for a few days to see if I get anything..
> full dmesg is here..: http://fpaste.org/jHSX/

Thanks for testing and please report if the issue is fixed.

Sujith
