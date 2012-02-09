From: Frans Meulenbroeks <fransmeulenbroeks@gmail.com>
Subject: Re: drivers/net/phy/phy.c issue
Date: Thu, 9 Feb 2012 09:12:01 +0100
Message-ID: <CACW_hTad_DtwR7FqqOjzvCOzbdj1PcSCEyUpg6d-G5VtDi3wbQ@mail.gmail.com>
References: <CACW_hTY41xZV6d0W2Z2kRfKOfa+RSQ-A-BoZsZwNXSQmeF_6Gg@mail.gmail.com>
	<1328729420.2261.329.camel@groeck-laptop>
	<CACW_hTbLd3kbuwJy9U2ZGDi3ypD-+KsecjYhku7jwQgFPaRqhg@mail.gmail.com>
	<20120208150548.32643cmtaxtymzok@67.228.131.195>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: guenter.roeck@ericsson.com, netdev@vger.kernel.org,
	"afleming@freescale.com" <afleming@freescale.com>,
	"macro@linux-mips.org" <macro@linux-mips.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: guenter@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120208150548.32643cmtaxtymzok@67.228.131.195>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/2/8  <guenter@roeck-us.net>:
> Quoting "Frans Meulenbroeks" <fransmeulenbroeks@gmail.com>:
>

[...]
>> Apologies, but I cannot test on a git head kernel.
>>
>> And wrt the question of Andy in the subsequent reply.
>>
>> Hw is a Freescale MPC8313. This is a Gianfar. Is that the info you wanted?
>>
> This is the MAC. Andy was asking for the PHY chip.
>
Sorry yes.
The mac is a Marvell 88e1111bab
I suspect this to be the same as in the MPC8313RDS reference design as
this design borrows quite some stuff from it.

Frans
