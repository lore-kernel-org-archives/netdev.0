From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 9p: client: remove unused code and any reference to
 "cancelled" function
Date: Tue, 30 Jul 2013 15:54:50 -0700 (PDT)
Message-ID: <20130730.155450.370003633888422808.davem@davemloft.net>
References: <20130725061411.GA8579@nautica>
	<1374742464-10686-1-git-send-email-andi@etezian.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dominique.martinet@cea.fr, pebolle@tiscali.nl, lucho@ionkov.net,
	ericvh@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, v9fs-developer@lists.sourceforge.net,
	rminnich@sandia.gov
To: andi@etezian.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374742464-10686-1-git-send-email-andi@etezian.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Shyti <andi@etezian.org>
Date: Thu, 25 Jul 2013 10:54:24 +0200

> This patch reverts commit
> 
> 80b45261a0b263536b043c5ccfc4ba4fc27c2acc
> 
> which was implementing a 'cancelled' functionality to notify that
> a cancelled request will not be replied.
> 
> This implementation was not used anywhere and therefore removed.
> 
> Signed-off-by: Andi Shyti <andi@etezian.org>

Applied, thanks Andi.
