From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH net-next 0/4] cxgb4i: Add ipv6 support
Date: Wed, 16 Jul 2014 01:08:49 -0700
Message-ID: <20140716080849.GA29924@infradead.org>
References: <1405479353-2289-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-scsi@vger.kernel.org, davem@davemloft.net,
	roland@purestorage.com, hch@infradead.org, michaelc@cs.wisc.edu,
	jbottomley@parallels.com, kxie@chelsio.com, leedom@chelsio.com,
	hariprasad@chelsio.com, swise@opengridcomputing.com
To: Anish Bhatt <anish@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1405479353-2289-1-git-send-email-anish@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Anish,

the scsi side changes looks fine to me.  Unless you have major updates
to the scsi driver for 3.17 that could cause conflicts I'm fine with
merging the whole series in through the networking tree.

