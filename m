From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Mon, 25 Feb 2008 12:17:12 +0000
Message-ID: <1203941832.2979.0.camel@shinybook.infradead.org>
References: <200801291316.m0TDGivY024953@hera.kernel.org>
	 <1203428949.3223.25.camel@shinybook.infradead.org>
	 <47BAE13D.4060206@trash.net>
	 <1203431447.3223.33.camel@shinybook.infradead.org>
	 <47BAEB6C.1030609@trash.net>
	 <1203666762.5771.35.camel@shinybook.infradead.org>
	 <47BEE31D.7020003@trash.net> <47BEEC5C.4060201@netfilter.org>
	 <47BEEDEF.5060503@trash.net>
	 <1203719866.5771.81.camel@shinybook.infradead.org>
	 <47C2B09A.1040102@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, netdev@vger.kernel.org,
	Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com,
	twoerner@redhat.com,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47C2B09A.1040102@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2008-02-25 at 13:12 +0100, Patrick McHardy wrote:
> 
> Yes, the kernel headers need to be fixed as well to not include
> linux/compiler.h outside of #ifdef __KERNEL__. I'll take care
> of that.

No. When you run 'make headers_install' that's already taken care of.

-- 
dwmw2

