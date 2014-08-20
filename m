From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity protection
Date: Wed, 20 Aug 2014 11:28:21 +0200
Message-ID: <CAPh34mc8eGqLyGrq1AH6AP5yBGnJgePkK03Ys-Zhw9cz9h3Y2g@mail.gmail.com>
References: <52A75EF8.3010308@in.tum.de>
	<20131211.150137.368953964178408437.davem@davemloft.net>
	<52A8C8B4.4060109@in.tum.de>
	<20131211122637.75b09074@nehalam.linuxnetplumber.net>
	<87bo0nulkt.fsf@tassilo.jf.intel.com>
	<52A8ECF5.3070604@in.tum.de>
	<20131212012317.GL21717@two.firstfloor.org>
	<52A98DBF.4090702@appelbaum.net>
	<52A9A17F.6050505@in.tum.de>
	<1386858864.19078.60.camel@edumazet-glaptop2.roam.corp.google.com>
	<53F3A739.4070203@ahsoftware.de>
	<CAPh34mckmKkRqG7M=37hHRJjBzZ+43BaPnjvpC5sEFnpPqj0aA@mail.gmail.com>
	<53F4654C.10101@ahsoftware.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christian Grothoff <grothoff@in.tum.de>,
	Jacob Appelbaum <jacob@appelbaum.net>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	knock@gnunet.org
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53F4654C.10101@ahsoftware.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 20 August 2014 11:07, Alexander Holler <holler@ahsoftware.de> wrote:

> For sure it could be better, but I'm already happy with the current
> imperfect solution which I can use now and not some perfect solution which
> might be available in some years.

Alexander, to make it clear: we cannot include mechanisms which
probably open other (security) issues. This is not how things work
out. TCP had so many issues in the past - regarding security,
implementation f*ups, etc. pp. It is utterly important that there is
no problem with an extension. Please join the discussion ob tcpm if
you will drive things forward. That's all what I can say - sorry!
