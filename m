From: Christoph Hellwig <hch@lst.de>
Subject: Re: simplify configfs attributes V2
Date: Sun, 11 Oct 2015 15:10:56 +0200
Message-ID: <20151011131056.GC3890@lst.de>
References: <1443879179-22280-1-git-send-email-hch@lst.de> <874mhzu3io.fsf@saruman.tx.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nicholas Bellinger <nab@linux-iscsi.org>,
	Andrzej Pietrasiewicz <andrzej.p@samsung.com>,
	Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	Pantelis Antoniou <pantelis.antoniou@konsulko.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <target-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <874mhzu3io.fsf@saruman.tx.rr.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 09, 2015 at 04:37:51PM -0500, Felipe Balbi wrote:
> For reference, I'm fine if you guys take all patches through FS
> tree. Another option is waiting for dependencies to be merged in v4.4,
> and the gadget changes merge in v4.5, whatever works.

I'd prefer to take them all in one go.  If we really have to I could
drop the last patch for now and clean up later, but I'd prefer not to.
