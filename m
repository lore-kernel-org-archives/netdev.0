From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH netfilter-next] xt_osf: Use continue to reduce indentation
Date: Wed, 17 Dec 2014 11:51:25 +0300
Message-ID: <8632531418806285@web23h.yandex.ru>
References: <1418761033.14140.5.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1418761033.14140.5.camel@perches.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi everyone

16.12.2014, 23:17, "Joe Perches" <joe@perches.com>:
> Invert logic in test to use continue.
>
> This routine already uses continue, use it a bit more to
> minimize > 80 column long lines and unnecessary indentation.
>
> No change in compiled object file.

Looks good. Thank you.
Which tree should this patch go through? Please pull it in.

Acked-by: Evgeniy Polyakov <zbr@ioremap.net>
