From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH|RFC] IPv6: have a proxy discard link-local traffic
Date: Tue, 03 Feb 2004 17:19:52 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040203.171952.105535895.yoshfuji@linux-ipv6.org>
References: <Pine.LNX.4.44.0401170906160.9907-100000@netcore.fi>
	<Pine.LNX.4.58.0401272259160.28384@rhea.tcs.hut.fi>
	<20040128115910.0a83e906.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, pekkas@netcore.fi, usagi-core@linux-ipv6.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20040128115910.0a83e906.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040128115910.0a83e906.davem@redhat.com> (at Wed, 28 Jan 2004 11:59:10 -0800), "David S. Miller" <davem@redhat.com> says:

> On Tue, 27 Jan 2004 23:11:20 +0200 (EET)
> Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:
> 
> > Dave, since even Pekka is now convinced this patch doesn't break anything,
> > would you consider applying it? :)
> 
> Yoshfuji asked for some time, so let us give it to him so he
> may analyze your change without rushing.

David, I'm (or we're) ok with this patch. Please apply. Thanks.
(But I still do not eat the proxy ND patch.)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
