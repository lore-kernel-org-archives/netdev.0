From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch net-next] ipv6: unify conntrack reassembly expire
 code with standard one
Date: Fri, 24 Aug 2012 18:13:28 +0800
Message-ID: <1345803208.11584.30.camel@cr0>
References: <1345190565-21689-1-git-send-email-amwang@redhat.com>
	 <1826853.rak2U42CMU@alaris> <1345453599.22373.9.camel@cr0>
	 <20120820202109.GB28790@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120820202109.GB28790@unicorn.suse.cz>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Michal,

Could you help to test my updated patches?

You can find them (the most top 4 patches) in my github tree:
https://github.com/congwang/linux/commits/ipv6

which is based on net-next.

I tried to setup the environment to reproduce it, but failed. I also
tried scapy, but I still can't trigger "Fragment Reassembly Timeout".

Thanks a lot!


