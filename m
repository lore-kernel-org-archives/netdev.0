From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [SCTP] Fix potential null pointer dereference while
 handling an icmp error
Date: Mon, 18 Jul 2005 13:44:27 -0700 (PDT)
Message-ID: <20050718.134427.112314130.davem@davemloft.net>
References: <1121302485.5841.30.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@oss.sgi.com,
        cdeboys@stevens.edu
Return-path: <netdev-bounce@oss.sgi.com>
To: sri@us.ibm.com
In-Reply-To: <1121302485.5841.30.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 13 Jul 2005 17:54:45 -0700

> Please apply the following patch which fixes a potential null pointer
> dereference while handling an icmp error in sctp_icmp_* routines. These
> routines assume that we are passing a valid asoc.
> 
> Reported by Charles-Henri de Boysson <cdeboys@stevens.edu>

Applied, thanks Sridhar.
