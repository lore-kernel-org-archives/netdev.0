From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] IPV6: Refcount leaks in udpv6_connect()
Date: Mon, 16 Jun 2003 05:02:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616.050207.104061458.davem@redhat.com>
References: <20030615.002656.35017399.davem@redhat.com>
	<Pine.LNX.4.44.0306161209030.15528-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0306161209030.15528-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ville Nuorvala <vnuorval@tcs.hut.fi>
   Date: Mon, 16 Jun 2003 12:22:57 +0300 (EEST)
   
   Hmm, odd. Perhaps the inlining of the patch mangled it somehow. Anyhow,
   here's a bk treediff against CS 1.1318 as an attachment.

Thanks, I've applied your fix.
