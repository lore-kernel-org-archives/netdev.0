From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Use C99 initializers in net/ipv6
Date: Mon, 03 Mar 2003 01:30:13 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030303.013013.93812658.davem@redhat.com>
References: <20030228.065944.08980219.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030228.065944.08980219.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Fri, 28 Feb 2003 06:59:44 +0900 (JST)

   This convers net/ipv6/{addrconf,route,sit}.c files to use C99
   initializers.  We don't touch net/ipv6/exthdrs.c for now because
   it will conflicts with our patch for IPsec.

Applied, thanks.
