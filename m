From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Prevent crash on ip_conntrack removal
Date: Sun, 29 Aug 2004 21:28:13 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040829212813.5807d478.davem@davemloft.net>
References: <412A8FB5.4080700@trash.net>
	<OFE08A3DF5.09BCA1C4-ON88256EFA.00806C05-88256EFA.0080E98F@us.ibm.com>
	<20040828231529.051a73cc.davem@davemloft.net>
	<4132303C.2060807@trash.net>
	<20040829125708.5aa70469.davem@davemloft.net>
	<4132516E.7080805@trash.net>
	<20040829163821.2a4239df.davem@davemloft.net>
	<413279C2.8020400@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, davem@redhat.com, laforge@netfilter.org,
        netdev@oss.sgi.com, netdev-bounce@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, okir@suse.de
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <413279C2.8020400@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 30 Aug 2004 02:50:10 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Great, here is the patch for 2.4 for the conntrack problem.

Applied, along with the 2.6.x variant plus the synchronize_net()
fix for 2.6.x
