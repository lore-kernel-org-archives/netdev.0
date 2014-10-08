From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] netlabel: directly return
 netlbl_unlabel_genl_init()
Date: Wed, 08 Oct 2014 16:09:18 -0400 (EDT)
Message-ID: <20141008.160918.1583864613017567450.davem@davemloft.net>
References: <1412793421-9914-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, paul@paul-moore.com,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412793421-9914-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed,  8 Oct 2014 20:37:01 +0200

> No need to store netlbl_unlabel_genl_init result and test it before returning.
> 
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
