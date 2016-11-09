From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [swiotlb PATCH v3 0/3] Add support for DMA writable pages being
 writable by the network stack.
Date: Wed, 9 Nov 2016 16:23:41 -0500
Message-ID: <20161109212341.GC12670@char.us.oracle.com>
References: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 09, 2016 at 10:19:57AM -0500, Alexander Duyck wrote:
> This patch series is a subset of the patches originally submitted with the
> above patch title.  Specifically all of these patches relate to the
> swiotlb.
> 
> I wasn't sure if I needed to resubmit this series or not.  I see that v2 is
> currently sitting in the for-linus-4.9 branch of the swiotlb git repo.  If
> no updates are required for the previous set then this patch set can be
> ignored since most of the changes are just cosmetic.

I already had tested v2 so if you have patches that you want to put on top
of that please do send them.
