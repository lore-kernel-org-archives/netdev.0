From: "David S. Miller" <davem@redhat.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Wed, 11 Feb 2004 22:41:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211224113.1a80c1a8.davem@redhat.com>
References: <20040212.110328.103131455.yoshfuji@linux-ipv6.org>
	<OF3D503D9D.B62072AD-ON88256E38.001BCCBD-88256E38.0023E0FA@us.ibm.com>
	<20040212.153911.64115196.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: dlstevens@us.ibm.com, hibi665@oki.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20040212.153911.64115196.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 12 Feb 2004 15:39:11 +0900 (JST)
YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> wrote:

> In article <OF3D503D9D.B62072AD-ON88256E38.001BCCBD-88256E38.0023E0FA@us.ibm.com> (at Wed, 11 Feb 2004 23:34:37 -0700), David Stevens <dlstevens@us.ibm.com> says:
> 
> >       What I intended is for ipv6_is_mld() to check this (not
> > assume that "skb" is ICMPv6 only). Fixed patch below [blush].
> >       Thanks for the reviews,
> :
> 
> I'll eat this patch.  Comments, if any?

If you both agree I guess it's time for me to apply it :-)

Someone give me a condensed one-line description for the patch, thanks.

Note the stuff I'm applying these days is destined for 2.6.4-pre1, I'll only
send simple one-liner serious bug fixes for 2.6.3-rcX
