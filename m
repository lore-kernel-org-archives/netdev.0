From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: (usagi-users 02436) Re: IPv6 bugs introduced in 2.4.21
Date: Thu, 19 Jun 2003 08:37:23 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0306190836310.14861-100000@netcore.fi>
References: <20030619.010753.75976590.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: jeroen@unfix.org, <netdev@oss.sgi.com>, <info@sixxs.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: usagi-users@linux-ipv6.org
In-Reply-To: <20030619.010753.75976590.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In article <003401c335ad$1c0cc880$210d640a@unfix.org> (at Wed, 18 Jun 2003 17:20:10 +0200), "Jeroen Massar" <jeroen@unfix.org> says:
> 
> > Is there a toggle for turning this behaviour off ?
> 
> Switch forwarding off.
> Routers are REQUIRED to be enabled.

Does the same happen with any other prefix length (e.g. the prefix::/126)?  
Otherwise, it's just a (un)fortunate bug.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
