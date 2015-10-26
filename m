From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] commit c6825c0976fa7893692e0e43b09740b419b23c09
 upstream.
Date: Mon, 26 Oct 2015 21:06:33 +0100
Message-ID: <20151026200633.GA13476@salvia>
References: <alpine.OSX.2.20.1510261144390.3919@athabasca.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	netdev@vger.kernel.org, coreteam@netfilter.org,
	Florian Westphal <fw@strlen.de>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Zefan Li <lizefan@huawei.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Neal P. Murphy" <neal.p.murphy@alum.wpi.edu>
To: Ani Sinha <ani@arista.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.OSX.2.20.1510261144390.3919@athabasca.local>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, Oct 26, 2015 at 11:55:39AM -0700, Ani Sinha wrote:
> netfilter: nf_conntrack: fix RCU race in nf_conntrack_find_get

Please, no need to Cc everyone here. Please, submit your Netfilter
patches to netfilter-devel@vger.kernel.org.

Moreover, it would be great if the subject includes something
descriptive on what you need, for this I'd suggest:

[PATCH -stable 3.4,backport] netfilter: nf_conntrack: fix RCU race in nf_conntrack_find_get

I'm including Neal P. Murphy, he said he would help testing these
backports, getting a Tested-by: tag usually speeds up things too.

Burden is usually huge here, the easier you get it for us, the best.
Then we can review and, if no major concerns, I can submit this to
-stable.

Let me know if you have any other questions,
Thanks.
