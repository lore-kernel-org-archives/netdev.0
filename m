From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Mon, 31 Jan 2005 14:16:36 +0900 (JST)
Message-ID: <20050131.141636.20664459.yoshfuji@linux-ipv6.org>
References: <E1CvSuS-00056x-00@gondolin.me.apana.org.au>
	<20050131.134559.125426676.yoshfuji@linux-ipv6.org>
	<41FDBB78.2050403@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        rmk+lkml@arm.linux.org.uk, Robert.Olsson@data.slu.se, akpm@osdl.org,
        torvalds@osdl.org, alexn@dsv.su.se, kas@fi.muni.cz,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kaber@trash.net, kozakai@linux-ipv6.org
In-Reply-To: <41FDBB78.2050403@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <41FDBB78.2050403@trash.net> (at Mon, 31 Jan 2005 06:00:40 +0100), Patrick McHardy <kaber@trash.net> says:

|We don't need this for IPv6 yet. Once we get nf_conntrack in we
|might need this, but its IPv6 fragment handling is different from
|ip_conntrack, I need to check first.

Ok. It would be better to have some comment but anyway...
kozakai-san?

--yoshfuji
