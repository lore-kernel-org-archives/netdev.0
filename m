From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] inet: frags: remove inline on static in c
 file
Date: Tue, 04 Nov 2014 15:12:19 -0500 (EST)
Message-ID: <20141104.151219.123276315019924380.davem@davemloft.net>
References: <1415130244-15003-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415130244-15003-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Tue,  4 Nov 2014 20:44:04 +0100

> remove __inline__ / inline and let compiler decide what to do
> with static functions
> 
> Inspired-by: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
