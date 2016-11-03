From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [mm PATCH v2 01/26] swiotlb: Drop unused functions
 swiotlb_map_sg and swiotlb_unmap_sg
Date: Thu, 3 Nov 2016 10:29:52 -0400
Message-ID: <20161103142952.GJ28691@localhost.localdomain>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com>
 <20161102111211.79519.39931.stgit@ahduyck-blue-test.jf.intel.com>
 <20161103141446.GA29720@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@intel.com>, linux-mm@kvack.org,
        akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <20161103141446.GA29720@infradead.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 03, 2016 at 07:14:46AM -0700, Christoph Hellwig wrote:
> On Wed, Nov 02, 2016 at 07:12:31AM -0400, Alexander Duyck wrote:
> > There are no users for swiotlb_map_sg or swiotlb_unmap_sg so we might as
> > well just drop them.
> 
> FYI, I sent the same patch already on Sep, 11 and Konrad already ACKed
> it:
> 
> https://lkml.org/lkml/2016/9/11/112
> https://lkml.org/lkml/2016/9/16/474

Somehow I thought you wanted to put them through your tree (which
is why I acked them).

I can take them and also the first couple of Alexander through
my tree. Or if it makes it simpler - they can go through the -mm tree?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
