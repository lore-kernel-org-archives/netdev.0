From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Do you know the linux TCP stack?
Date: Sat, 5 Mar 2005 10:39:29 -0800
Message-ID: <20050305103929.46255b6c.davem@davemloft.net>
References: <E1D7aML-0007Wp-00@smtp01.mrf.mail.rcn.net>
	<E1D7aML-0007Wp-00@smtp01.mrf.mail.rcn.net>
	<E1D7cr7-0006TO-00@smtp06.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <E1D7cr7-0006TO-00@smtp06.mrf.mail.rcn.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


The routing entry used is in "skb->dst", cast it to a
"struct rtentry *" and look at the contents.

$5000.00USD please :-)
