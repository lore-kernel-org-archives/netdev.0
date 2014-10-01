From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] ieee802154: fix __init functions
Date: Wed, 01 Oct 2014 02:03:30 -0400 (EDT)
Message-ID: <20141001.020330.1107419144608142662.davem@davemloft.net>
References: <1412141266-12258-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, alex.aring@gmail.com,
	linux-wpan@vger.kernel.org, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1412141266-12258-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed,  1 Oct 2014 07:27:46 +0200

> Commit 3243acd37fd9
> ("ieee802154: add __init to lowpan_frags_sysctl_register")
> 
> added __init to lowpan_frags_ns_sysctl_register instead of
> lowpan_frags_sysctl_register
> 
> Suggested-by: Alexander Aring <alex.aring@gmail.com>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied, thanks for sorting this out.
