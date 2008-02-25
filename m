From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Mon, 25 Feb 2008 13:23:26 +0100
Message-ID: <47C2B33E.2020608@trash.net>
References: <200801291316.m0TDGivY024953@hera.kernel.org>	 <1203428949.3223.25.camel@shinybook.infradead.org>	 <47BAE13D.4060206@trash.net>	 <1203431447.3223.33.camel@shinybook.infradead.org>	 <47BAEB6C.1030609@trash.net>	 <1203666762.5771.35.camel@shinybook.infradead.org>	 <47BEE31D.7020003@trash.net> <47BEEC5C.4060201@netfilter.org>	 <47BEEDEF.5060503@trash.net>	 <1203719866.5771.81.camel@shinybook.infradead.org>	 <47C2B09A.1040102@trash.net>	 <1203941832.2979.0.camel@shinybook.infradead.org>	 <47C2B29A.5090100@trash.net> <1203942105.2979.2.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
	Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com,
	twoerner@redhat.com,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1203942105.2979.2.camel@shinybook.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Woodhouse wrote:
> On Mon, 2008-02-25 at 13:20 +0100, Patrick McHardy wrote:
>> Right, I missed that. In that case the current headers should match
>> the kernel headers (with the compiler.h part removed).
> 
> They don't. When you run 'make headers_install' there are some missing.


We don't need all of them, but I'll do a proper resync. Thanks.

