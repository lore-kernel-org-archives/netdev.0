From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Tue, 10 Jun 2003 09:56:06 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030610.095606.23033683.davem@redhat.com>
References: <20030609203659.089b241b.nakam@linux-ipv6.org>
	<3EE5F85E.9080006@tml.hut.fi>
	<20030611004035.40027642.nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lpetande@tml.hut.fi, yoshfuji@linux-ipv6.org, vnuorval@tcs.hut.fi,
   kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, ajtuomin@morphine.tml.hut.fi,
   jagana@us.ibm.com, kumarkr@us.ibm.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: nakam@linux-ipv6.org
In-Reply-To: <20030611004035.40027642.nakam@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Masahide NAKAMURA <nakam@linux-ipv6.org>
   Date: Wed, 11 Jun 2003 00:40:44 +0900
   
   How about providing interface of handling templates to update
   existing policy in kernel?

Who will manage mipv6 policies?  racoon?  See my other email
on why any other setup simply will not work.
