From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NET] 2.6.x build warning
Date: Thu, 26 May 2005 16:06:40 -0700 (PDT)
Message-ID: <20050526.160640.45179958.davem@davemloft.net>
References: <42961EDB.7000407@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <42961EDB.7000407@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jeff Garzik <jgarzik@pobox.com>
Date: Thu, 26 May 2005 15:09:15 -0400

> from current git tree:
> 
> net/ipv6/ip6_flowlabel.c: In function `ipv6_flowlabel_opt':
> net/ipv6/ip6_flowlabel.c:540: warning: ignoring return value of 
> `copy_to_user', declared with attribute warn_unused_result

I've fixed this warning in my tree, thanks Jeff.
