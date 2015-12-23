From: Henri Roosen <henri.roosen@ginzinger.com>
Subject: Re: [PATCH 1/1] phy: micrel: Fix finding PHY properties in MAC node
 for KSZ9031.
Date: Wed, 23 Dec 2015 09:11:22 +0100
Message-ID: <567A572A.4030207@ginzinger.com>
References: <1450781920-26912-1-git-send-email-henri.roosen@ginzinger.com>
 <20151222110634.GC2373@lunn.ch>
 <20151222.171444.1073714139867888727.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ginzinger.com ([31.193.165.229]:17626 "EHLO
	mail.ginzinger.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933475AbbLWIUl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 03:20:41 -0500
In-Reply-To: <20151222.171444.1073714139867888727.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2015 11:14 PM, David Miller wrote:
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Tue, 22 Dec 2015 12:06:34 +0100
>
>> On Tue, Dec 22, 2015 at 11:58:40AM +0100, Henri Roosen wrote:
>>> Commit 651df2183543 ("phy: micrel: Fix finding PHY properties in MAC
>>>   node.") only fixes finding PHY properties in MAC node for KSZ9021. This
>>> commit applies the same fix for KSZ9031.
>>>
>>> Signed-off-by: Henri Roosen <henri.roosen@ginzinger.com>
>>
>> Fixes: 8b63ec1837fa ("phylib: Make PHYs children of their MDIO bus, not the bus' parent.")
>>
>> Acked-by: Andrew Lunn <andrew@lunn.ch>
>
> This does not apply cleanly to any of my trees.

David, does the original patch not apply cleanly or is your comment only
on the message from Andrew?

Else please let me know what is wrong with the original patch. I've
tested it applies cleanly to v4.4-rc6 and to v4.3.

>

________________________________

Ginzinger electronic systems GmbH
Gewerbegebiet Pirath 16
4952 Weng im Innkreis
www.ginzinger.com

Firmenbuchnummer: FN 364958d
Firmenbuchgericht: Ried im Innkreis
UID-Nr.: ATU66521089

________________________________
*** WEIHNACHTSURLAUB VON DONNERSTAG, DEN 24. DEZEMBER 2015 BIS MITTWOCH, DEN 6. JAENNER 2016 ***
*** CHRISTMAS VACATION FROM THURSDAY, THE 24 DECEMBER 2015 TO WEDNESDAY, 6 JANUARY 2016 ***
