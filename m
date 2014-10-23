From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 00/14] net: dsa: Fixes and enhancements
Date: Wed, 22 Oct 2014 22:22:45 -0700
Message-ID: <544890A5.5090807@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net> <CAGVrzcbohXf09pvrzayZEfcpjr8U-h-hyuYMnU0yTBJny0U27A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGVrzcbohXf09pvrzayZEfcpjr8U-h-hyuYMnU0yTBJny0U27A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/22/2014 09:45 PM, Florian Fainelli wrote:
> 2014-10-22 21:03 GMT-07:00 Guenter Roeck <linux@roeck-us.net>:
>> Patch 01/14 addresses an annoying and unhelpful log message.
>>
>> Patches 02/14 and 03/14 are minor enhancements, adding support for
>> known switch revisions.
>>
>> Patches 04/14 and 05/14 add support for MV88E6352 and MV88E6176.
>>
>> Patch 06/14 adds support for hardware monitoring, specifically for
>> reporting the chip temperature, to the dsa subsystem.
>>
>> Patches 07/14 and 08/14 implement hardware monitoring for MV88E6352,
>> MV88E6176, MV88E6123, MV88E6161, and MV88E6165.
>>
>> Patch 09/14 adds support for EEPROM access to the DSA subsystem.
>>
>> Patch 10/14 implements EEPROM access for MV88E6352 and MV88E6176.
>>
>> Patch 11/14 adds support for reading switch registers to the DSA
>> subsystem.
>>
>> Patches 12/14 amd 13/14 implement support for reading switch registers
>> to the drivers for MV88E6352, MV88E6176, MV88E6123, MV88E6161, and MV88E6165.
>>
>> Patch 14/14 adds support for reading additional RMON registers to the drivers
>> for  MV88E6352, MV88E6176, MV88E6123, MV88E6161, and MV88E6165.
>>
>> The series resides and was tested on top of v3.18-rc1 in a system
>> with MV88E6352. Testing in systems with 88E6131, 88E6060 and MV88E6165
>> was done earlier (I don't have access to those systems right now).
>> The series applies cleanly to net-next as of today (10/22).
>
> Besides the two nitpicking comments, this looks really good to me, thanks!
>
Thanks a lot for the quick review!

I'll wait a couple of days for additional feedback before I resubmit.

Guenter
