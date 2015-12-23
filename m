From: Henri Roosen <henri.roosen@ginzinger.com>
Subject: Re: [PATCH 1/1] phy: micrel: Fix finding PHY properties in MAC node
 for KSZ9031.
Date: Wed, 23 Dec 2015 09:42:24 +0100
Message-ID: <567A5E70.1010407@ginzinger.com>
References: <1450781920-26912-1-git-send-email-henri.roosen@ginzinger.com>
 <20151222110634.GC2373@lunn.ch>
 <20151222.171444.1073714139867888727.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 8BIT
Cc: <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151222.171444.1073714139867888727.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



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

Found the problem. It's the mail server. Will send a correct patch later.

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
