From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] make sendmsg return EDESTADDRREQ if socket is not
 connected and daddr was not specified
Date: Fri, 11 Jul 2003 09:37:01 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711.093701.109452621.yoshfuji@linux-ipv6.org>
References: <20030710233223.GA30577@rei.rakuen>
	<20030711.093546.12708723.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
In-Reply-To: <20030711.093546.12708723.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030711.093546.12708723.yoshfuji@linux-ipv6.org> (at Fri, 11 Jul 2003 09:35:46 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20030710233223.GA30577@rei.rakuen> (at Fri, 11 Jul 2003 01:32:23 +0200), Thomas Graf <tgraf@suug.ch> says:
> 
> > [EDESTADDRREQ]
> >     The socket is not connection-mode and does not have its peer
> >     address set, and no destination address was specified.
> > 
> > fixes sendmsg in ipv{4,6}/{raw,udp}
> 
> I aggeed on this, however we may want to do for whole tree at same time.
    ~~~~~~agreed
> How do you think, folks?

--yoshfuji
