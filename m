From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: BUG: dst underflow (again)
Date: Fri, 22 Oct 2004 15:51:59 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041022.155159.98771450.yoshfuji@linux-ipv6.org>
References: <4178AB0D.6060107@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <4178AB0D.6060107@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <4178AB0D.6060107@pobox.com> (at Fri, 22 Oct 2004 02:39:09 -0400), Jeff Garzik <jgarzik@pobox.com> says:

> As requested, I updated my kernel to see if the "BUG: dst underflow..." 
> messages disappeared.  Alas, they didn't.  dmesg and .config from 
> 2.6.9-final attached.

Okay, thanks, but hmm...
(We haven't met this issue... I really want to know tow to reproduce...)

> Let me know what additional debugging information I can provide, if any. 
>   The symbol addresses in the dmesg output are all inside the ipv6 module.

Would you enable CONFIG_KALLSYMS_ALL, please?

Thanks.

--yoshfuji
