From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/5] ipvs: Lock socket before setting SK_CAN_REUSE
Date: Mon, 13 Jun 2016 20:18:23 -0700
Message-ID: <1465874303.7945.181.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465868613-26146-1-git-send-email-quentin@armitage.org.uk>
	 <1465868613-26146-5-git-send-email-quentin@armitage.org.uk>
	 <1465873924.7945.180.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org
To: Quentin Armitage <quentin@armitage.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1465873924.7945.180.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-06-13 at 20:12 -0700, Eric Dumazet wrote:

> 
> Have you tested this patch ?

Hmm, please ignore this question ;)
