From: Grant Grundler <grantgrundler@gmail.com>
Subject: Re: [PATCH] net: tulip: update MAINTAINER status to Orphan
Date: Thu, 19 Nov 2015 18:41:36 -0800
Message-ID: <CAP6odjhdsmZs9JRXsTfFVrYf1C66gOzQr=1Bs6M+L8LhPkheLg@mail.gmail.com>
References: <1447984572-23959-1-git-send-email-grantgrundler@gmail.com>
	<564E857A.4020609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"open list:TULIP NETWORK DRI..." <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>,
	Helge Deller <deller@gmx.de>,
	Grant Grundler <grundler@parisc-linux.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <564E857A.4020609@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 19, 2015 at 6:29 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> On 19/11/15 17:56, Grant Grundler wrote:
>> From: Grant Grundler <grundler@parisc-linux.org>
>>
>> I haven't had any PCI tulip HW for the past ~5 years. I have
>> been reviewing tulip patches and can continue doing that.
>>
>> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
>> ---
>> I'm also proposing to add linux-parisc to the list since AFAIK, all
>> parisc systems but the C8000 workstations (PA8800/PA8900 CPU)
>> use tulip for onboard LAN.
>>
>> Specific mips and alpha systems also care about tulip driver too.
>> But I don't know either well enough to suggest respective mailing
>> lists should see every tulip patch.
>
> For MIPS, is not Cobalt the primary (and sole) user?

Once upon a time a Mips based router was using tulip as well. I know
they needed to "borrow" some tulip patches that were only in
parisc-linux source tree (for reasons I don't see a need to repeat
here).

> You could add linux-mips@linux-mips.org if that helps.

I wanted to let the mips folks decide if they should be listed....and
CC'd Helga (parisc maintainer) in case he objected to added
linux-parisc mailing list.

cheers,
grant

> My Cobalt stayed behind me when
> I moved to the US, so outside of Yoichi, I am not sure who else cares
> these days...
>
>>
>>  MAINTAINERS | 4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index ea17512..ec07061 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -10888,9 +10888,9 @@ S:    Maintained
>>  F:   drivers/media/tuners/tua9001*
>>
>>  TULIP NETWORK DRIVERS
>> -M:   Grant Grundler <grundler@parisc-linux.org>
>>  L:   netdev@vger.kernel.org
>> -S:   Maintained
>> +L:   linux-parisc@vger.kernel.org
>> +S:   Orphan
>>  F:   drivers/net/ethernet/dec/tulip/
>>
>>  TUN/TAP driver
>>
>
>
> --
> Florian
