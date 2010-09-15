From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: nat: add nf_nat_csum()
Date: Wed, 15 Sep 2010 19:26:10 +0200
Message-ID: <4C9101B2.5090602@trash.net>
References: <1283575541-23101-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1283575541-23101-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 04.09.2010 06:45, schrieb Changli Gao:
> Add a static function nf_nat_csum() to replace the duplicate code in
> nf_nat_mangle_udp_packet() and __nf_nat_mangle_tcp_packet().
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Looks good to me. Applied, thanks.
