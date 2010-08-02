From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v2] nf_nat: no IP_NAT_RANGE_MAP_IPS flags when alloc_null_binding()
Date: Mon, 02 Aug 2010 17:41:03 +0200
Message-ID: <4C56E70F.7090708@trash.net>
References: <1280673907-12619-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1280673907-12619-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01.08.2010 16:45, Changli Gao wrote:
> when alloc_null_binding(), no IP_NAT_RNAGE_MAP_IPS in flags means no IP address
> translation is needed. It isn't necessary to specify the address explicitly.

When sending updated patches, you have to tell people what has changed.
