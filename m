From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6: Fix large packet length check
Date: Tue, 24 Jun 2003 14:51:51 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030624.145151.28812624.davem@redhat.com>
References: <20030624.124030.123761150.yoshfuji@linux-ipv6.org>
	<Mutt.LNX.4.44.0306241846150.5688-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Mutt.LNX.4.44.0306241846150.5688-100000@excalibur.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Tue, 24 Jun 2003 18:47:26 +1000 (EST)

   On Tue, 24 Jun 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
   
   > This patch fixes the problem.
   > Patch against [PATCH] IPV6: use macro for maximum payload length patch.
   
   I've applied both of these to bk://kernel.bkbits.net/jmorris/net-2.5

Thanks James, I've pulled them.
