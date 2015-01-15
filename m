From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Remove T4 FCoE support
Date: Thu, 15 Jan 2015 14:04:53 -0500 (EST)
Message-ID: <20150115.140453.871607276763972458.davem@davemloft.net>
References: <cover.1421328605.git.praveenm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	JBottomley@parallels.com, hch@infradead.org,
	hariprasad@chelsio.com, varun@chelsio.com
To: praveenm@chelsio.com
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <cover.1421328605.git.praveenm@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Praveen Madhavan <praveenm@chelsio.com>
Date: Thu, 15 Jan 2015 19:15:50 +0530

> These patches removes FCoE support for chelsio T4 adapter.
> Please apply on net-next since depends on previous commits.

Why is it being removed?  You have to state this in the
commit log messages at a minimum.
