From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPv6 multicast (MLD,IGMP) code bypasses netfilter hooks
Date: Sun, 23 Nov 2003 22:44:14 -0800
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20031123224414.0bea3633.davem@redhat.com>
References: <OFBBD13E53.65F0744F-ON88256DE7.003D0DE0@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFBBD13E53.65F0744F-ON88256DE7.003D0DE0@us.ibm.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

On Sun, 23 Nov 2003 04:13:39 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> Here's a patch to add netfilter hooks for MLD v1 & v2. Can you take
> quick look at it, Harald?

Whoa, David beat me to it, on a weekend no less :)))

It looks good to me.  Applied, thanks.
