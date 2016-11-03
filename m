From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [mm PATCH v2 01/26] swiotlb: Drop unused functions
 swiotlb_map_sg and swiotlb_unmap_sg
Date: Thu, 3 Nov 2016 07:14:46 -0700
Message-ID: <20161103141446.GA29720@infradead.org>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
 <20161102111211.79519.39931.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20161102111211.79519.39931.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 02, 2016 at 07:12:31AM -0400, Alexander Duyck wrote:
> There are no users for swiotlb_map_sg or swiotlb_unmap_sg so we might as
> well just drop them.

FYI, I sent the same patch already on Sep, 11 and Konrad already ACKed
it:

https://lkml.org/lkml/2016/9/11/112
https://lkml.org/lkml/2016/9/16/474

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
