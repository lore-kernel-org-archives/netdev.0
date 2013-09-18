From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [PATCH] powerpc/83xx: gianfar_ptp: select 1588 clock source through
 dts file
Date: Wed, 18 Sep 2013 18:44:15 +0300
Message-ID: <5239CA4F.9000600@freescale.com>
References: <1379510464-25420-1-git-send-email-aida.mynzhasova@skitlab.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>
To: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe002.messaging.microsoft.com ([207.46.163.25]:6544 "EHLO
	co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751218Ab3IRPo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 11:44:27 -0400
In-Reply-To: <1379510464-25420-1-git-send-email-aida.mynzhasova@skitlab.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 9/18/2013 4:21 PM, Aida Mynzhasova wrote:
> IEEE 1588 timer reference clock source is determined through hard-coded
> value in gianfar_ptp driver by default. This patch allows to select ptp
> clock source by means of device tree file node.
>
> For instance:
>
> 	fsl,cksel = <0>;
>

Has this device tree binding been defined? (Where?)
I don't see this property in the net-next.git tree at least.

Claudiu
