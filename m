From: Jan Engelhardt <jengelh@computergmbh.de>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Fri, 22 Feb 2008 17:03:35 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0802221700050.26109@fbirervta.pbzchgretzou.qr>
References: <200801291316.m0TDGivY024953@hera.kernel.org>
 <1203428949.3223.25.camel@shinybook.infradead.org>  <47BAE13D.4060206@trash.net>
  <1203431447.3223.33.camel@shinybook.infradead.org>  <47BAEB6C.1030609@trash.net>
 <1203666762.5771.35.camel@shinybook.infradead.org> <47BEE31D.7020003@trash.net>
 <47BEEC5C.4060201@netfilter.org> <47BEEDEF.5060503@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Woodhouse <dwmw2@infradead.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com,
	twoerner@redhat.com,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47BEEDEF.5060503@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Feb 22 2008 16:44, Patrick McHardy wrote:
> Pablo Neira Ayuso wrote:
>> Patrick McHardy wrote:
>> > Yes, that was a bug in the lastest release. We need to
>> > release a 1.4.1 version or something like that, but I'm
>> > not too familiar with the release process, so I haven't
>> > done this so far.
>> 
>> I can schedule one for this weekend, just send me an ACK.
>
>
> That would be great. I think we had another issue in 1.4.0 with
> some header files, but I can't remeber the details.
>
> Jan, I recall we talked about this some time ago, do you remember?

I dunno, in Xtables 1.5.1 all header problems (minus
the "uint32_t all" in nf_inet_addr) are resolved I believe.
The thing even compiles without a kernel source now.
