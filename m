From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] ppp: don't use 0 in pointer context
Date: Thu, 9 Feb 2006 09:51:10 +1100
Message-ID: <17386.30174.791963.518883@cargo.ozlabs.ibm.com>
References: <E1F6xei-0006hc-00@gondolin.me.apana.org.au>
	<OF71FA79DA.C4F20DA5-ON8825710F.007B701A-8825710F.007CB97E@us.ibm.com>
	<20060208.144712.66821895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, herbert@gondor.apana.org.au,
	adobriyan@gmail.com, carlsonj@workingcode.com,
	linux-ppp@vger.kernel.org, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <linux-ppp-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060208.144712.66821895.davem@davemloft.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller writes:

> Because sparse goes beyond the standards and tries to
> catch cases that usually end up being bugs.

When has a pointer comparison with an explicit "0" ever caused a bug?

Paul.
