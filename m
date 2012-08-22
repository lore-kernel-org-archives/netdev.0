From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/18] net: core: add function for incremental IPv6
 pseudo header checksum updates
Date: Wed, 22 Aug 2012 02:28:24 -0700 (PDT)
Message-ID: <20120822.022824.342287347329595698.davem@davemloft.net>
References: <1345434006-16549-1-git-send-email-kaber@trash.net>
	<1345434006-16549-9-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345434006-16549-9-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 20 Aug 2012 05:39:56 +0200

> Add inet_proto_csum_replace16 for incrementally updating IPv6 pseudo header
> checksums for IPv6 NAT.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

This is fine too:

Acked-by: David S. Miller <davem@davemloft.net>
