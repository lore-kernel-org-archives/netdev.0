From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 2/3] add dev_to_node()
Date: Sun, 5 Nov 2006 00:09:16 +0100
Message-ID: <20061104230916.GA32188@lst.de>
References: <20061030141501.GC7164@lst.de> <20061030.143357.130208425.davem@davemloft.net> <20061104225629.GA31437@lst.de> <20061104230648.GB640@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965737AbWKDXJ3@vger.kernel.org>
To: Dave Jones <davej@redhat.com>, Christoph Hellwig <hch@lst.de>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-mm@kvack.org
Content-Disposition: inline
In-Reply-To: <20061104230648.GB640@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 04, 2006 at 06:06:48PM -0500, Dave Jones wrote:
> On Sat, Nov 04, 2006 at 11:56:29PM +0100, Christoph Hellwig wrote:
> 
> This will break the compile for !NUMA if someone ends up doing a bisect
> and lands here as a bisect point.
> 
> You introduce this nice wrapper..

Yes, I'm stupid :)  Updated version will follow ASAP.
