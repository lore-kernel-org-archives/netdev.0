From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: How to get the IPv6 address of next hop towards destination?
Date: Fri, 29 Nov 2002 13:16:56 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021129.131656.766932499.yoshfuji@linux-ipv6.org>
References: <000d01c2975d$a2ad3c10$6c06a8c0@zhengjp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, roque@di.fc.ul.pt, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: zjp@iscas.ac.cn
In-Reply-To: <000d01c2975d$a2ad3c10$6c06a8c0@zhengjp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <000d01c2975d$a2ad3c10$6c06a8c0@zhengjp> (at Fri, 29 Nov 2002 12:13:13 +0800), "Zheng Jianping" <zjp@iscas.ac.cn> says:

> It seems  that
>   u8   primary_key[0];
> is responsible for it.
> 
> Is it right?

yes.

--yoshfuji
