From: Michal Simek <michal.simek@petalogix.com>
Subject: Re: [PATCH] [V2] net: add Xilinx emac lite device driver
Date: Thu, 20 Aug 2009 11:28:48 +0200
Message-ID: <4A8D1750.4000804@petalogix.com>
References: <20090819122920.37EE21728051@mail110-dub.bigfish.com> <20090820.022536.264747725.davem@davemloft.net>
Reply-To: michal.simek@petalogix.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: john.linn@xilinx.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, sadanan@xilinx.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:65316 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210AbZHTJ2w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 05:28:52 -0400
Received: by bwz19 with SMTP id 19so5234544bwz.37
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 02:28:52 -0700 (PDT)
In-Reply-To: <20090820.022536.264747725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: John Linn <john.linn@xilinx.com>
> Date: Wed, 19 Aug 2009 06:29:11 -0600
>
>   
>> This patch adds support for the Xilinx Ethernet Lite device.  The
>> soft logic core from Xilinx is typically used on Virtex and Spartan
>> designs attached to either a PowerPC or a Microblaze processor.
>>
>> Signed-off-by: Sadanand M <sadanan@xilinx.com>
>> Signed-off-by: John Linn <john.linn@xilinx.com>
>>     
>
> Looks good, applied to net-next-2.6, thanks!
>   
There were one bug with spinlock which John L fixed but not send to
mainling list. :-(
He wanted to create new v3 version. :-(.
When he wake up, he send you that bug fix or v3 version with it.

Regards,
Michal


-- 
Michal Simek, Ing. (M.Eng)
PetaLogix - Linux Solutions for a Reconfigurable World
w: www.petalogix.com p: +61-7-30090663,+42-0-721842854 f: +61-7-30090663

