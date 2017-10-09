From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v1 RFC 1/7] Replace license with GPL
Date: Mon, 9 Oct 2017 12:40:15 -0700
Message-ID: <45a93e39-6530-fc1b-7808-51750691a470@gmail.com>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
 <1507321985-15097-2-git-send-email-Tristram.Ha@microchip.com>
 <063D6719AE5E284EB5DD2968C1650D6DD008D3F0@AcuExch.aculab.com>
 <93AF473E2DA327428DE3D46B72B1E9FD4112EE49@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: muvarov@gmail.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        andrew@lunn.ch, pavel@ucw.cz, ruediger.schmitt@philips.com
To: Tristram.Ha@microchip.com, David.Laight@ACULAB.COM
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD4112EE49@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/09/2017 11:40 AM, Tristram.Ha@microchip.com wrote:
>> From: Tristram.Ha@microchip.com
>>> Sent: 06 October 2017 21:33
>>> Replace license with GPL.
>>
>> Don't you need permission from all the people who have updated
>> the files in order to make this change?
>>
>> 	David
> 
> I am a little confused by your comment.  The 4 original KSZ9477 DSA
> driver files were written by Woojung at Microchip Technology Inc.
> There was a complaint the "AS IS" license is not exactly GPL.
> 
> It should be submitted formally to net-next instead of a RFC, but it
> is probably pointless to do that when there is no code change.
> 
> I am hoping these drastic changes of KSZ9477 driver can be accepted
> so that the patches can be submitted formally to net-next.

What David is saying is that you need to take into account every one who
has been making changes to the Microchip driver, because anytime
someones submits a patch that gets accepted, their "voice" now counts:

Fortunately, the list seems to be fairly limited:

git shortlog -sne drivers/net/dsa/microchip
     5  Arkadi Sharshevsky <arkadis@mellanox.com>
     1  Woojung Huh <Woojung.Huh@microchip.com>

So seeking contributor approval for a license change should be fairly
simple.
-- 
Florian
