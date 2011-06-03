From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [TRIVIAL PATCH next 15/15] net: Convert vmalloc/memset to vzalloc
Date: Fri, 03 Jun 2011 11:39:16 +0200
Message-ID: <4DE8ABC4.5060404@netfilter.org>
References: <cover.1306603968.git.joe@perches.com>	<045996b9688bfaa2efbd8999405a67e23cd0a075.1306603968.git.joe@perches.com>	<4DE7A311.5000406@netfilter.org> <20110602.143927.1073346459383432955.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, kaber@trash.net, andy.grover@oracle.com,
	trivial@kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	rds-devel@oss.oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110602.143927.1073346459383432955.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/06/11 23:39, David Miller wrote:
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Thu, 02 Jun 2011 16:49:53 +0200
> 
>> Are you going to take this patch? it includes one chunck which is out of
>> netfilter scope.
> 
> I think the trivial folks submit these things via their own tree
> and are only looking for ACKs from us.
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>
