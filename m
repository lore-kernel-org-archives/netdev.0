From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] make sendmsg return EDESTADDRREQ if socket is not
 connected and daddr was not specified
Date: Fri, 11 Jul 2003 09:41:36 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711.094136.38023048.yoshfuji@linux-ipv6.org>
References: <20030710233223.GA30577@rei.rakuen>
	<20030711.093546.12708723.yoshfuji@linux-ipv6.org>
	<20030710.172923.27804984.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030710.172923.27804984.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030710.172923.27804984.davem@redhat.com> (at Thu, 10 Jul 2003 17:29:23 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:

>    From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
>    Date: Fri, 11 Jul 2003 09:35:46 +0900 (JST)
>    
>    I aggeed on this, however we may want to do for whole tree at same time.
>    How do you think, folks?
> 
> Sure, just send more patches relative to this one :-)

Okay, I'll do this as much as I can do...

--yoshfuji
