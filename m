From: "Zheng Jianping" <zjp@iscas.ac.cn>
Subject: Re: How to get the IPv6 address of next hop towards destination?
Date: Thu, 12 Dec 2002 10:11:24 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <005f01c2a183$c590bce0$6c06a8c0@zhengjp>
References: <000d01c2975d$a2ad3c10$6c06a8c0@zhengjp> <20021129.131656.766932499.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "yoshfuji" <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, Yoshfuji,

What's type of the address stored in primary_key[0], link-local or global?

Thanks,
Zheng

> In article <000d01c2975d$a2ad3c10$6c06a8c0@zhengjp> (at Fri, 29 Nov 2002
12:13:13 +0800), "Zheng Jianping" <zjp@iscas.ac.cn> says:
>
> > It seems  that
> >   u8   primary_key[0];
> > is responsible for it.
> >
> > Is it right?
>
> yes.
>
> --yoshfuji
>
>
