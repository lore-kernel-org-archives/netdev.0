From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/13]: Netfilter IPsec support
Date: Wed, 23 Nov 2005 02:20:03 +0100
Message-ID: <4383C3C3.8040005@trash.net>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>	<20051122.143438.84749134.davem@davemloft.net>
	<20051123.073825.106706639.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net, kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20051123.073825.106706639.yoshfuji@linux-ipv6.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / $B5HF#1QL@ wrote:
> I believe he can manage these patches in his tree,
> but anyway...

It is kind of annoying redoing 13 patches for every small change.

> Well, it is very important to fix the packet processing
> path issues (including the extension header issue)
> before we merge it to the mainline. Definitely.
> What I want to ensure is that they will not reach the mainline
> tree without resolving those issues.

How about we put the IPv4 patches in now and I continue working
on the IPv6 side? The main approach is not going to change,
and I think users would appreciate having them available in
2.6.15.
