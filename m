From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] nf_nat: use local variable hdrlen
Date: Mon, 02 Aug 2010 17:16:23 +0200
Message-ID: <4C56E147.1040909@trash.net>
References: <1280476725-7637-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280476725-7637-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.07.2010 09:58, Changli Gao wrote:
> use local variable hdrlen instead of ip_hdrlen(skb).

Applied. But again, please prefix your subject lines with
"netfilter: " and use capital letters for the beginning of
a sentence as I asked you to.
