From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH resend] netfilter: nf_nat_core: don't check if the tuple
 is used if there is no other choice
Date: Thu, 16 Sep 2010 19:45:51 +0200
Message-ID: <4C9257CF.3080409@trash.net>
References: <1282029696-3028-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1282029696-3028-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17.08.2010 09:21, Changli Gao wrote:
> Eliminate nf_nat_used_tuple() to save some CPU cycles when there is no other
> choice.

Applied.
