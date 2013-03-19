From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: remove unused "config IP_NF_QUEUE"
Date: Wed, 20 Mar 2013 00:12:23 +0100
Message-ID: <20130319231223.GA4017@localhost>
References: <1363734599.1390.50.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1363734599.1390.50.camel@x61.thuisdomein>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 20, 2013 at 12:09:59AM +0100, Paul Bolle wrote:
> Kconfig symbol IP_NF_QUEUE is unused since commit
> d16cf20e2f2f13411eece7f7fb72c17d141c4a84 ("netfilter: remove ip_queue
> support"). Let's remove it too.

Applied, thanks for catching up this leftover.
