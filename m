From: =?UTF-8?B?TGVuYXIgTMO1aG11cw==?= <lenar@vision.ee>
Subject: Re: status of via velocity in 2.6.9
Date: Tue, 07 Dec 2004 10:44:53 +0200
Message-ID: <41B56D85.9080105@vision.ee>
References: <41B4F447.2060808@ccs.neu.edu> <41B56518.2070108@vision.ee> <20041207082106.GA24306@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
In-Reply-To: <20041207082106.GA24306@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Francois Romieu wrote:

>Lenar L=C3=B5hmus <lenar@vision.ee> :
>[...]
> =20
>
>>the machine just locked up after ifconfig up. With 2.6.9, it doesn't=20
>>lock up, but it doesn't work either (data seems to go to black hole
>>or sth). But there seem to be some success reports too with this kernel.
>>   =20
>>
>
>Can you check if the computer hosts the latest bios from its vendor and
> =20
>
At the time 2.6.9 was released it had latest bios.

>if booting with "acpi=3Doff" makes a difference ?
> =20
>
If I remember correctly - i tried, but no difference.

>The content of /proc/interrupts after a known number of TX packets could
>give some hint (use ping or such and correlate ifconfig output with
>/proc/interrupts).
> =20
>
With that I can't help, although the machine is accessible to me, it is=20
now 'in production' with 3Com NIC and so I
can't test and play with it anymore. When I get my hands on another=20
similar box and it still exhibits
same problems, I'll be back reporting it, and hopefully I have time to=20
test suggested things.

Lenar
