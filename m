From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address
 Autoconfiguration in IPv6
Date: Thu, 31 Oct 2002 16:49:40 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021031.164940.672083668.yoshfuji@linux-ipv6.org>
References: <20021031.163209.595697847.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0210310942030.19356-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, davem@redhat.com,
   kuznet@ms2.inr.ac.ru, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0210310942030.19356-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0210310942030.19356-100000@netcore.fi> (at Thu, 31 Oct 2002 09:43:40 +0200 (EET)), Pekka Savola <pekkas@netcore.fi> says:

> Generating and re-generating new temporary addresses seems to be a useless 
> work and just new addresses unless they're being used at least by some 
> applications.

set default to 0 (don't use it) for now is ok?

--yoshfuji
