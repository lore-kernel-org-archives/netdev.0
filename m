From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH net-next 5/5] gianfar_ethtool: coding style and whitespace
 cleanups
Date: Mon, 04 Jun 2012 21:11:09 +0200
Message-ID: <4FCD084D.6020408@computer.org>
References: <1338827516-18425-1-git-send-email-jan.ceuleers@computer.org> <1338827516-18425-6-git-send-email-jan.ceuleers@computer.org> <20120604.140850.1847853625568125563.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: b06378@freescale.com, joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay003.isp.belgacom.be ([195.238.6.53]:9262 "EHLO
	mailrelay003.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757163Ab2FDTO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 15:14:56 -0400
In-Reply-To: <20120604.140850.1847853625568125563.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2012 08:08 PM, David Miller wrote:
> From: Jan Ceuleers <jan.ceuleers@computer.org>
> Date: Mon,  4 Jun 2012 18:31:56 +0200
> 
>> -					sizeof(struct gfar_mask_entry),
>> -					gfar_comp, &gfar_swap);
>> +			     sizeof(struct gfar_mask_entry),
>> +			     far_comp, &gfar_swap);
> 
> Don't send me crap you haven't even compile tested.
> 
> I'm tossing this entire patch series out, don't resubmit until you've
> tested every single patch.
> 

Well then I'm sorry but I won't be resubmitting
