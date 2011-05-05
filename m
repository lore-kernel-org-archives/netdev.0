From: John Crispin <blogic@openwrt.org>
Subject: Re: [PATCH V2 2/3] MIPS: lantiq: add ethernet driver
Date: Fri, 06 May 2011 00:16:39 +0200
Message-ID: <4DC321C7.8060600@openwrt.org>
References: <1304633402-24161-1-git-send-email-blogic@openwrt.org>	<1304633402-24161-3-git-send-email-blogic@openwrt.org> <20110505.151049.35056363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, ralph.hempel@lantiq.com,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:36905 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752756Ab1EEWPE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 18:15:04 -0400
In-Reply-To: <20110505.151049.35056363.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/11 00:10, David Miller wrote:
> From: John Crispin <blogic@openwrt.org>
> Date: Fri,  6 May 2011 00:10:01 +0200
>
>   
>> This patch adds the driver for the ETOP Packet Processing Engine (PPE32) found
>> inside the XWAY family of Lantiq MIPS SoCs. This driver makes 100MBit ethernet
>> work. Support for all 8 dma channels, gbit and the embedded switch found on
>> the ar9/vr9 still needs to be implemented.
>>
>> Signed-off-by: John Crispin <blogic@openwrt.org>
>> Signed-off-by: Ralph Hempel <ralph.hempel@lantiq.com>
>>     
> No objections from me and this can go via the MIPS tree:
>
> Acked-by: David S. Miller <davem@davemloft.net>
>
>   
Thank you !


