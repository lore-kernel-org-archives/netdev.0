From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address
 Autoconfiguration in IPv6
Date: Thu, 31 Oct 2002 10:24:11 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210311021560.19356-100000@netcore.fi>
References: <20021031.164940.672083668.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, <netdev@oss.sgi.com>, <davem@redhat.com>,
   <kuznet@ms2.inr.ac.ru>, <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021031.164940.672083668.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Oct 2002, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> In article <Pine.LNX.4.44.0210310942030.19356-100000@netcore.fi> (at Thu, 31 Oct 2002 09:43:40 +0200 (EET)), Pekka Savola <pekkas@netcore.fi> says:
> 
> > Generating and re-generating new temporary addresses seems to be a useless 
> > work and just new addresses unless they're being used at least by some 
> > applications.
> 
> set default to 0 (don't use it) for now is ok?

Sure, ok for me.  (I'm assuming we'll be able to change the default at 
some point when more knowledge and experience is gained but we're talking 
about at least a year or two here, I think).

(This is why I never perceived privacy addresses as a critical work item 
at the moment -- e.g. multicast routing might be more interesting.)

I don't know how Dave and Alexey feel, of course.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
