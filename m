From: Franco Fichtner <franco@marian.de>
Subject: Re: [PATCH] at91_ether: Add Micrel KSZ8041 PHY support
Date: Wed, 17 Sep 2008 10:04:17 +0200
Message-ID: <48D0BA01.3060104@marian.de>
References: <cd73a99e0809161352s770e29fbs50b1b6995378211b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, gustavo@zacarias.com.ar,
	kernel@avr32linux.org
To: Andrew Victor <avictor.za@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.183]:49832 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbYIQIEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 04:04:31 -0400
In-Reply-To: <cd73a99e0809161352s770e29fbs50b1b6995378211b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Victor wrote:
> Add support for Micrel's KSZ8041 PHY in the Atmel AT91RM9200 Ethernet driver.
> The PHY is similar to the KS8721 (configuration registers differ a
> bit, like LED function and a new PHY Control 2 register and LinkMD
> control/status register, which aren't used by the at91_ether driver
> anyway). The chip has a different pin layout so it's no good for a
> drop in replacement anyway.
> 
> Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>
> Signed-off-by: Andrew Victor <linux@maxim.org.za>
> 

Added avr32 kernel list as CC.


Thanks,
Franco
