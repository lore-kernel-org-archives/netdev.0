From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: 32 bit (socket layer) ioctl emulation for 64 bit kernels - patch1
Date: Wed, 11 Jan 2006 12:33:20 +0000
Message-ID: <200601111233.21075.arnd@arndb.de>
References: <1136871078.5742.26.camel@spereira05.tusc.com.au> <200601101203.59423.arnd@arndb.de> <1136960688.5347.6.camel@spereira05.tusc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Andi Kleen <ak@muc.de>,
	linux-kenel <linux-kernel@vger.kernel.org>,
	x25 maintainer <eis@baty.hanse.de>,
	netdev <netdev@vger.kernel.org>, SP <pereira.shaun@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751452AbWAKMd2@vger.kernel.org>
To: spereira@tusc.com.au
In-Reply-To: <1136960688.5347.6.camel@spereira05.tusc.com.au>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 11 January 2006 06:24, Shaun Pereira wrote:
> =A0Thanks for reviewing those patches, and your feedback. I have made=
 the
> changes recommended. If these are acceptable, I will build a proper
> [PATCH] for submission.

This patch looks good to me now.

> Is there anyone in particular that I need to mail=20
> in order that these patches go into the next release?=20

I guess David Miller should be on Cc:, but I'm not sure who would
be the one to forward general networking patches. The MAINTAINERS
file only lists netdev@vger.kernel.org.

	Arnd <><
