From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6 MIB:ipv6Prefix netlink notification
Date: Fri, 5 Dec 2003 14:57:00 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031205145700.120e9e68.davem@redhat.com>
References: <200311191621.38087.mashirle@us.ibm.com>
	<200312051351.47962.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, xma@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <200312051351.47962.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 5 Dec 2003 13:51:47 -0800
Shirley Ma <mashirle@us.ibm.com> wrote:

> Once receiving a router advertisement message for prefix info, 
> a netlink notification event will be created.
> 
> This patch has been tested against linux-2.6.0-test11. 

Let's queue this up for 2.6.1, please resend it after 2.6.0 is
released.
