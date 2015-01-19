From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] csiostor:Remove T4 FCoE support
Date: Mon, 19 Jan 2015 15:30:37 -0500 (EST)
Message-ID: <20150119.153037.240478310106457112.davem@davemloft.net>
References: <cover.1421423434.git.praveenm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	JBottomley@parallels.com, hch@infradead.org,
	hariprasad@chelsio.com, varun@chelsio.com
To: praveenm@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <cover.1421423434.git.praveenm@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Praveen Madhavan <praveenm@chelsio.com>
Date: Fri, 16 Jan 2015 21:30:18 +0530

> We found a subtle issue with FCoE on T4 very late in the game
> and decided not to productize FCoE on T4 and therefore there
> are no customers that will be impacted by this change. FCoE is
> supported on T5 cards.
> 
> Please apply on net-next since depends on previous commits.
> 
> Changes in v2:
>   - Make the commit message more clearer.

Series applied, thanks.
