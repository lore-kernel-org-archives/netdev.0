From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] New Patch Implementation for IPv6
 MIB:ipv6InterfaceTable
Date: Mon, 20 Oct 2003 21:04:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031020210433.27e25240.davem@redhat.com>
References: <200310141032.23998.mashirle@us.ibm.com>
	<20031014152441.1be6b336.davem@redhat.com>
	<200310201600.10016.mashirle@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Shirley Ma <mashirle@us.ibm.com>
In-Reply-To: <200310201600.10016.mashirle@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 20 Oct 2003 16:00:09 -0700
Shirley Ma <mashirle@us.ibm.com> wrote:

> This is the new patch for IPv6 MIBs:ipv6InterfaceTable.
> This patch has been tested against linux-2.6.0-test8 kernel plus xfmr patch.
> 
> Please review it. 

It looks fine but I cannot merge it at this time.  Linus wants
only critical bug fixes for nowin 2.6.x

Maybe in 2.6.1, 2.6.2 or later we can merge this in.

Thanks.
