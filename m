From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ravb: add R8A7791 support
Date: Mon, 30 Nov 2015 22:08:22 +0300
Message-ID: <565C9EA6.309@cogentembedded.com>
References: <6051623.qN4lqSyZKg@wasted.cogentembedded.com>
 <CAMuHMdWE_G2WqsGZEaa4Ck3zziTLGVPfaVdU2gbnLA5zWpmR1w@mail.gmail.com>
 <565B6AAD.8080205@cogentembedded.com> <20151130004207.GD3501@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux-sh list <linux-sh@vger.kernel.org>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Simon Horman <horms@verge.net.au>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20151130004207.GD3501@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/30/2015 03:42 AM, Simon Horman wrote:

>>>> Add support  for yet another ARM member of the R-Car family, R-Car M2, also
>>
>>> R-Car M2-W?
>>
>>     Right, forgot about the postfixes.
>>
>>>> known as R8A7791.
>>>
>>> There's also R-Car M2-N, aka R8A7793, but you probably know that ;-)
>>
>>     Will fix.
>
> I would prefer if we added generic gen2 and gen3 compat strings to the driver
> and only documented new soc-specific compat strings.

    That's a new policy it seems. Previously you preferred the SoC-specific 
strings to be used, didn;t you?

> Actually by chance I was planning to up patches to do that and add compat
> strings for the missing Gen2 boards. But I won't complain if you beat me to
> it.

    No, I'm pretty busy as is. :-)

MBR, Sergei

