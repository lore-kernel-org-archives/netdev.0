From: Quentin Schulz <quentin.schulz@free-electrons.com>
Subject: Re: [PATCH v2] can: m_can: enable transmission of FD frame on latest
 version
Date: Fri, 7 Apr 2017 13:41:11 +0200
Message-ID: <2d0bf188-7c80-9dd7-87ec-ef6e4f685f5b@free-electrons.com>
References: <20170306022143.7695-1-wenyou.yang@atmel.com>
 <e4360c52-d62d-6c35-f691-7fcd0f74f954@pengutronix.de>
 <b24f3252-6bd9-db48-b224-5bf3683cb75d@hartkopp.net>
 <fe3a4152-643c-404f-f236-5066089fba2e@hartkopp.net>
 <F9F4555C4E01D7469D37975B62D0EFBB4FC29C@CHN-SV-EXMX07.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: alexandre.belloni@free-electrons.com, f.fainelli@gmail.com,
        nicolas.ferre@atmel.com, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Wenyou.Yang@microchip.com, socketcan@hartkopp.net,
        mkl@pengutronix.de, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <F9F4555C4E01D7469D37975B62D0EFBB4FC29C@CHN-SV-EXMX07.mchp-main.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Oliver and Marc,

On 07/03/2017 02:03, Wenyou.Yang@microchip.com wrote:
> HI Oliver, 
> 
>> -----Original Message-----
>> From: Oliver Hartkopp [mailto:socketcan@hartkopp.net]
>> Sent: 2017年3月7日 5:26
>> To: Marc Kleine-Budde <mkl@pengutronix.de>; Wenyou Yang - A41535
>> <Wenyou.Yang@microchip.com>; Wolfgang Grandegger <wg@grandegger.com>
>> Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>; Florian Fainelli
>> <f.fainelli@gmail.com>; Quentin Schulz <quentin.schulz@free-electrons.com>;
>> Wenyou Yang - A41535 <Wenyou.Yang@microchip.com>; Nicolas Ferre
>> <nicolas.ferre@atmel.com>; linux-can@vger.kernel.org; netdev@vger.kernel.org;
>> linux-kernel@vger.kernel.org
>> Subject: Re: [PATCH v2] can: m_can: enable transmission of FD frame on latest
>> version
>>
>> @Wenyou Yang: Can you please test the two patches posted here:
> 
> Tested on SAMA5D2 SoC, It works.
> 
>>
>> [PATCH 1/2] can: m_can: handle bitrate setup on IP core >= 3.1.x
>> http://marc.info/?l=linux-can&m=148883529927720&w=2
>>
>> [PATCH 2/2] can: m_can: handle frame transmission on IP core >= 3.1.x
>> http://marc.info/?l=linux-can&m=148883529927718&w=2
>>

Sorry, never received those mails so didn't know I had to do something.
I forgot to add my Signed-off-by when resending it so of course you can
add it to your next version:

Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>

That gives me the opportunity to relaunch the discussion on it. What's
the status?

Quentin

>> Tnx & regards,
>> Oliver
> 
> Thank you.
> 
> Best Regards,
> Wenyou Yang
> 

-- 
Quentin Schulz, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
