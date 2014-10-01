From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] inet: frags: add __init to
 ip4_frags_ctl_register
Date: Wed, 01 Oct 2014 15:46:31 -0400 (EDT)
Message-ID: <20141001.154631.1628551566252748883.davem@davemloft.net>
References: <1412183937-16055-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412183937-16055-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed,  1 Oct 2014 19:18:57 +0200

> ip4_frags_ctl_register is only called by __init ipfrag_init
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
