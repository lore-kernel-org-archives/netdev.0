From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net/phy: micrel: Follow attached_dev to get to the MAC
 device
Date: Sat, 17 Oct 2015 22:23:23 +0300
Message-ID: <5622A02B.3040000@cogentembedded.com>
References: <1445028545-22599-1-git-send-email-andrew@lunn.ch>
 <5621890E.8090704@cogentembedded.com> <20151016235408.GB28795@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dinh Nguyen <dinguyen@opensource.altera.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:33795 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750984AbbJQTX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Oct 2015 15:23:26 -0400
Received: by lbbwb3 with SMTP id wb3so57826181lbb.1
        for <netdev@vger.kernel.org>; Sat, 17 Oct 2015 12:23:25 -0700 (PDT)
In-Reply-To: <20151016235408.GB28795@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/17/2015 2:54 AM, Andrew Lunn wrote:

>>> Commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus, not
>>> the bus' parent." broke finding PHY properties in the MAC device tree
>>
>>     You probably forgot to run checkpatch.pl on this patch, else it
>> would have complained about the commit citing style. It's <12-bit
>> SHA1> ("<summary line>").
>
> Actual, i did, and decided to ignore it. I'm quoting the regression
> report, which formats it that way.

    BTW, I'm seeing no Reported-by: tag in your patch either, is that intended?

> 	   Andrew

MBR, Sergei
