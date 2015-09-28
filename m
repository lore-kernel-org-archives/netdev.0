From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 23/23] configfs: remove old API
Date: Mon, 28 Sep 2015 15:42:14 +0200
Message-ID: <20150928134214.GE30453@lst.de>
References: <1443189000-13398-1-git-send-email-hch@lst.de> <1443189000-13398-24-git-send-email-hch@lst.de> <56092D2E.1000400@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felipe Balbi <balbi@ti.com>, Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Andrzej Pietrasiewicz <andrzej.p@samsung.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <56092D2E.1000400@samsung.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Haven't you just removed show_attribute() and store_attribute() from
> configfs_item_operations?

Oops, looks like the old text manage to slip back in.  I'll fix it up.
