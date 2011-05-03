From: Paul McEnery <pmcenery@gmail.com>
Subject: Re: [PATCH] ipheth.c: Enable IP header alignment
Date: Tue, 3 May 2011 18:33:58 +0100
Message-ID: <BANLkTi=W5HTLDa-UEvk4TefP3FyOvphxew@mail.gmail.com>
References: <1304264799.2833.82.camel@localhost>
	<1304364912-15444-1-git-send-email-agimenez@sysvalve.es>
	<1304370274.2833.192.camel@localhost>
	<20110503165751.GA6566@bart.evergreen.loc>
	<710D4D6CE160654C87478D18385BB9971BE3FDCA46@MDC-MAIL-CMS01.ubisoft.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
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
In-Reply-To: <710D4D6CE160654C87478D18385BB9971BE3FDCA46@MDC-MAIL-CMS01.ubisoft.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3 May 2011 18:18, David Hill <david.hill@ubisoft.com> wrote:
>
> Maybe I can help on this part.
>
> Git ?
>
> I'm using ubuntu natty ... The part =A0I'm not sure of is , do I patc=
h ubuntu's kernel or I start from scratch?
>

If we can get the patch committed to the Github ipheth repo, I'll
package it in my Ubuntu PPA. You can then simply install ipheth-dkms
which allow it to replace the in-tree module for testing...

I unfortunately cannot test either, since I no longer have an iPhone.

Paul.
