From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPV6: convert /proc/net/ip6_flowlabel to seq_file
Date: Tue, 1 Jul 2003 00:49:52 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0307010048540.24506-100000@excalibur.intercode.com.au>
References: <20030630.230115.84925092.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030630.230115.84925092.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 30 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

> In article <20030629.015723.75141662.yoshfuji@linux-ipv6.org> (at Sun, 29 Jun 2003 01:57:23 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:
> 
> > This converts /proc/net/ip6_flowlabel to seq_file{}.
> > Thanks.
> 
> Oops, this was buggy.  Here's fixed one...
> 

This has already been pushed to Dave's tree.  Could you please generate a 
diff against bk://kernel.bkbits.net/jmorris/net-2.5?

(Not sure what state Dave's tree is in, but it may work against that).


- James
-- 
James Morris
<jmorris@intercode.com.au>
