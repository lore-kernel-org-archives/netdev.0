From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] ipv6: remove inline on static in c file
Date: Thu, 30 Oct 2014 15:52:52 -0400 (EDT)
Message-ID: <20141030.155252.46450705810333675.davem@davemloft.net>
References: <1414579097-11659-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414579097-11659-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed, 29 Oct 2014 11:38:17 +0100

> remove __inline__ / inline and let compiler decide what to do
> with static functions
> 
> Inspired-by: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
