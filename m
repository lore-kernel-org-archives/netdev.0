From: Paul McEnery <pmcenery@gmail.com>
Subject: Re: [PATCH] ipheth.c: Enable IP header alignment
Date: Tue, 3 May 2011 23:45:40 +0100
Message-ID: <BANLkTi=Xt_DrHRmf8SViiAwgkAjCFLVX7A@mail.gmail.com>
References: <1304264799.2833.82.camel@localhost>
	<1304364912-15444-1-git-send-email-agimenez@sysvalve.es>
	<1304370274.2833.192.camel@localhost>
	<20110503165751.GA6566@bart.evergreen.loc>
	<710D4D6CE160654C87478D18385BB9971BE3FDCA46@MDC-MAIL-CMS01.ubisoft.org>
	<BANLkTi=W5HTLDa-UEvk4TefP3FyOvphxew@mail.gmail.com>
	<710D4D6CE160654C87478D18385BB9971BE3FDCA5C@MDC-MAIL-CMS01.ubisoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: =?ISO-8859-1?Q?L=2E_Alberto_Gim=E9nez?= <agimenez@sysvalve.es>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"dgiagio@gmail.com" <dgiagio@gmail.com>,
	"dborca@yahoo.com" <dborca@yahoo.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"open list:USB SUBSYSTEM" <linux-usb@vger.kernel.org>,
	"open list:NETWORKING DRIVERS" <netdev@vger.kernel.org>
To: David Hill <david.hill@ubisoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <710D4D6CE160654C87478D18385BB9971BE3FDCA5C@MDC-MAIL-CMS01.ubisoft.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3 May 2011 18:41, David Hill <david.hill@ubisoft.com> wrote:
> That's not a problem, I can test it :)
>

I have applied Ben Hutching's patch [1] to the Github repository [2].
Updated Debian/Ubuntu packages are now available for testing [3].

Please test and report back. I'm sure Ben would also like to know if
this fix work :)

[1] - https://lkml.org/lkml/2011/5/3/283
[2] - https://github.com/dgiagio/ipheth/commit/46d6db65e0054cfae6f7355200b83f04e2fb9042
[3] - https://launchpad.net/~pmcenery/+archive/ppa
