From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>
Subject: Re: Difference between skb_put() and skb_push()
Date: Thu, 31 Mar 2005 14:54:42 +0900 (JST)
Message-ID: <20050331.145442.70843060.yoshfuji@wide.ad.jp>
References: <72252ed05033021463a1f45b6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux781@gmail.com
In-Reply-To: <72252ed05033021463a1f45b6@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <72252ed05033021463a1f45b6@mail.gmail.com> (at Thu, 31 Mar 2005 00:46:03 -0500), Akshay Kawale <linux781@gmail.com> says:

> I was wondering about the difference between skb_put() and skb_push().
> Both appear to take in the same parameters and produce the same result
> - that of lengthening the data area.
> 
> If I wanted to add data before the current data area, which one should I use?
> (e.g. my data is 5678... and I wanted to prepend 1234 to it).

http://www.skbuff.net/skbbasic.html

--yoshfuji
