From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH + RFC] neighbour/ARP cache scalability
Date: Wed, 22 Sep 2004 00:59:45 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922.005945.93612032.yoshfuji@linux-ipv6.org>
References: <20040921134918.GK1307@sunbeam.de.gnumonks.org>
	<20040922.001448.73843048.yoshfuji@linux-ipv6.org>
	<16720.19049.100640.24977@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, pekkas@netcore.fi, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se
In-Reply-To: <16720.19049.100640.24977@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <16720.19049.100640.24977@robur.slu.se> (at Tue, 21 Sep 2004 17:36:09 +0200), Robert Olsson <Robert.Olsson@data.slu.se> says:

>  Remember we discussed this with at OLS? Asking for my solution.I said 
>  ask at IETF as you were going there. I guess it was not discussed?

Yes, I remember.

I talked with KAME (*BSD) developers.
I don't think that the BSD's behavior is good enough against the threats.
So, I think we should find by ourselves.

--yoshfuji
