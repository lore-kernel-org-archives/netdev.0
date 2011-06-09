From: Nicolas Cavallari <Nicolas.Cavallari@lri.fr>
Subject: Re: [PATCH] netfilter: fix looped (broad|multi)cast's bogus MACs in NFQUEUE
Date: Thu,  9 Jun 2011 15:39:07 +0200
Message-ID: <1307626748-10992-1-git-send-email-cavallar@lri.fr>
References: <20110608153032.GA26912@Chamillionaire.breakpoint.cc>
To: fw@strlen.de, kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20110608153032.GA26912@Chamillionaire.breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> nfnetlink_log has the same problem.

I also figured from source that ip_queue has the same problem too, so
the next patch fixes that too.

