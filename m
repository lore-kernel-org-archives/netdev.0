From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [BUG] can't unload network device's if IPV6 is loaded
Date: Tue, 16 Dec 2003 12:55:25 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031216.125525.119981521.yoshfuji@linux-ipv6.org>
References: <20031211153334.0c59214b.shemminger@osdl.org>
	<1071467514.3219.11.camel@mentor.gurulabs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dax@gurulabs.com, shemminger@osdl.org
In-Reply-To: <1071467514.3219.11.camel@mentor.gurulabs.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <1071467514.3219.11.camel@mentor.gurulabs.com> (at Sun, 14 Dec 2003 22:51:54 -0700), Dax Kelson <dax@gurulabs.com> says:

> I noticed this on my laptop with my internal Dell TrueMobile 1150
> wireless 802.11 card (orinoco_cs).
> 
> On my Fedora box when I added IPV6=yes to /etc/sysconfig/network I
> couldn't get clean reboots or shutdowns.

please provide your kernel config. thanks.
(I cannot reproduce the problem.)

--yoshfuji
