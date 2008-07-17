From: Jie Yang <Jie.Yang@Atheros.com>
Subject: RE: [PATCH net-next] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Thu, 17 Jul 2008 17:41:25 +0800
Message-ID: <72981EBCFD196144B7C6999B9FC34A9A3EE6131220@SHEXMB-01.global.atheros.com>
References: <12162854952457-git-send-email-jie.yang@atheros.com>
 <20080717093117.GA8373@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"yjwei@cn.fujitsu.com" <yjwei@cn.fujitsu.com>,
	"rdreier@cisco.com" <rdreier@cisco.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jcliburn@gmail.com" <jcliburn@gmail.com>,
	"parag.warudkar@gmail.com" <parag.warudkar@gmail.com>,
	"w@1wt.eu" <w@1wt.eu>,
	"oliver.schuster@schweigstill.de" <oliver.schuster@schweigstill.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 175.212.dsnet ([203.110.175.212]:24254 "EHLO mail.atheros.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752962AbYGQJla convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 05:41:30 -0400
In-Reply-To: <20080717093117.GA8373@martell.zuzino.mipt.ru>
Content-Language: zh-CN
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On  Thursday, July 17, 2008 5:31 PM
Alexey Dobriyan<adobriyan@gmail.com> wrote:
> Does it have the same 4G limitation as ATL1 card?
>
> If yes, pci_using_64 logic isn't needed, and copying comment
> from atl1 driver wouldn't hurt, If no, you're setting small DMA mask.
>
> --
yes,  it do have the limit.

Best wishes
jie
