From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Fri, 11 Jul 2003 14:04:28 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307111403450.27351-100000@netcore.fi>
References: <20030711.200357.33143193.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: mika.liljeberg@welho.com, <andre@tomt.net>, <linux-kernel@vger.kernel.org>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20030711.200357.33143193.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Jul 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In article <Pine.LNX.4.44.0307111358440.27351-100000@netcore.fi> (at Fri, 11 Jul 2003 13:59:14 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:
> 
> > > So, you cannot remove subnet router anycast address from
> > > kernel via this interface; kernel keeps one reference.
> > 
> > .. which is why kernel shouldn't keep *any* reference *at all*!
> 
> No, it is because REQUIRED and UNREMOVABLE anycast address.

Smells like a circular requirement :-)

> I don't think it is good to change this.

That's another issue entirely.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
