From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 IPComp
Date: Fri, 16 May 2003 14:00:14 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030516.140014.59676235.davem@redhat.com>
References: <87llx72imk.wl@karaba.org>
	<Mutt.LNX.4.44.0305162329230.17250-100000@excalibur.intercode.com.au>
	<873cjebwn1.wl@karaba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: mk@linux-ipv6.org
In-Reply-To: <873cjebwn1.wl@karaba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Mitsuru KANDA / 神田 充 <mk@linux-ipv6.org>
   Date: Sat, 17 May 2003 02:59:30 +0900

   but it may take a time because currently ip6ip6 does not exist.
   
Once you implement xfrm6_tunnel.c the problem is mostly solved.
You do not need to have an ip6ip6 device-like tunnel first.

I will integrate your patch, thanks.
