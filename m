From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [patch]: CONFIG_IPV6_SUBTREES fix for MIPv6
Date: Wed, 11 Jun 2003 00:40:44 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611004035.40027642.nakam@linux-ipv6.org>
References: <20030606223057.41ac1c9d.nakam@linux-ipv6.org>
	<Pine.GSO.4.44.0306091140470.25126-100000@morphine.tml.hut.fi>
	<20030609203659.089b241b.nakam@linux-ipv6.org>
	<3EE5F85E.9080006@tml.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, vnuorval@tcs.hut.fi,
   davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   ajtuomin@morphine.tml.hut.fi, jagana@us.ibm.com, kumarkr@us.ibm.com,
   usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Henrik Petander <lpetande@tml.hut.fi>
In-Reply-To: <3EE5F85E.9080006@tml.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003 18:25:18 +0300
Henrik Petander <lpetande@tml.hut.fi> wrote:

> Then the policies for mipv6 would need to be specified at the same time 
> as the ipsec policies. This is not a problem as long as the policies are 
>   loaded at start up. However, this could lead to problems with 
> applications which specify their own policies, e.g. racoon.

How about providing interface of handling templates to update
existing policy in kernel?

Regards,

-- 
Masahide NAKAMURA
