From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address
 Autoconfiguration in IPv6
Date: Mon, 03 Mar 2003 00:54:28 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030303.005428.96142819.davem@redhat.com>
References: <20021101.174832.44646503.yoshfuji@linux-ipv6.org>
	<20030223.223114.65976206.davem@redhat.com>
	<20030226.004155.71903869.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru,
   pekkas@netcore.fi, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20030226.004155.71903869.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
   Date: Wed, 26 Feb 2003 00:41:55 +0900 (JST)
   
   Well, I've found a bug that a temporary addresses were not
   re-generated properly.  Here's the patch for linux-2.5.63.

Fix applied, thanks.
