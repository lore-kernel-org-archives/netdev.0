From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] xfrm_user info leaks
Date: Thu, 20 Sep 2012 18:09:49 -0400 (EDT)
Message-ID: <20120920.180949.2287169159603922703.davem@davemloft.net>
References: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: minipli@googlemail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348090423-32665-1-git-send-email-minipli@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mathias Krause <minipli@googlemail.com>
Date: Wed, 19 Sep 2012 23:33:37 +0200

> the following series fixes various info leaks in the xfrm netlink
> interface. As always, a test case can be supplied on request.
> 
> Patches 1 to 5 are probably material for stable, too. Patch 6 is just a
> minor optimization I stumbled across while auditing the code.
> 
> Please apply!

All applied, and I made sure to use v3 of patch #5 (which you marked
as 5/7 instead of 5/6 :-)

Also, these have been queued up for -stable as well.

Thanks.
