From: "David S. Miller" <davem@redhat.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Fri, 6 Feb 2004 20:33:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206203330.60e63ba7.davem@redhat.com>
References: <20040206195325.207aa1c7.davem@redhat.com>
	<OF293C5854.C480643B-ON88256E33.0016BE45-88256E33.0016EBE0@us.ibm.com>
	<20040206202438.13163677.davem@redhat.com>
	<20040207.132937.126838355.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: dlstevens@us.ibm.com, hibi665@oki.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040207.132937.126838355.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 07 Feb 2004 13:29:37 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <20040206202438.13163677.davem@redhat.com> (at Fri, 6 Feb 2004 20:24:38 -0800), "David S. Miller" <davem@redhat.com> says:
> 
> > On Fri, 6 Feb 2004 21:12:59 -0700
> > David Stevens <dlstevens@us.ibm.com> wrote:
> > 
> > > @@ -211,16 +219,11 @@
> > > 
> > >  int ip6_mc_input(struct sk_buff *skb)
> 
> We should test the destination address here.

Ok, you and David work things out and let me know when the final
patch is ready.
