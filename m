From: "Yusuke.Goda" <goda.yusuke@renesas.com>
Subject: Re: smc911x: Add AP325RXA board support
Date: Thu, 05 Jun 2008 12:00:19 +0900
Message-ID: <484756C3.4010900@renesas.com>
References: <4846744B.4000407@renesas.com>
 <aec7e5c30806041855j604311b8xad79d9050897d0f1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.renesas.com ([202.234.163.13]:56339 "EHLO
	mail05.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750769AbYFEDA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 23:00:26 -0400
In-reply-to: <aec7e5c30806041855j604311b8xad79d9050897d0f1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Magnus-san

Magnus Damm wrote:
> Hi Goda-san,
> 
> On Wed, Jun 4, 2008 at 7:54 PM, Yusuke.Goda <goda.yusuke@renesas.com> wrote:
>> This patch adds AP325RXA board support to scc911x driver.
> 
> I posted a few patches recently (smc911x: Request bus width using
> platform data) that are conflicting with your patch. Hopefully my
> patches will be included in 2.6.27, and at that point we can modify
> the ap32x board code to add board specific configuration to the
> smc911x platform data.

I'm sorry I did not watch your patch.
With your patch, my patch was not necessary.

Thanks,
Goda

