From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [RFC v2 00/10] HFI Virtual Network Interface Controller (VNIC)
Date: Wed, 18 Jan 2017 09:46:43 -0700
Message-ID: <20170118164643.GB14198@obsidianresearch.com>
References: <20161215091226.GC811@mtr-leonro.local>
 <20161215145212.GA29116@phlsvsds.ph.intel.com>
 <380b05bf-a18e-1f20-7e8e-10b61f77dec7@redhat.com>
 <20161215170713.GD3264@obsidianresearch.com>
 <4e22bf29-2260-0768-ab17-9a8df6306f37@redhat.com>
 <20161215184837.GA16552@obsidianresearch.com>
 <20161216012404.GD3785@phlsvsds.ph.intel.com>
 <20161216041727.GA3797@obsidianresearch.com>
 <20170117192720.GA2833@knc-06.sc.intel.com>
 <20170118054354.GT32481@mtr-leonro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura@intel.com>,
        "ira.weiny" <ira.weiny@intel.com>,
        Doug Ledford <dledford@redhat.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        dennis.dalessandro@intel.com
To: Leon Romanovsky <leon@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:39742 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750943AbdARRYF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 12:24:05 -0500
Content-Disposition: inline
In-Reply-To: <20170118054354.GT32481@mtr-leonro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 18, 2017 at 07:43:54AM +0200, Leon Romanovsky wrote:
> > I have started working on porting hfi_vnic as per this new interface.
> > I will post RFC v3 later.
> > Posting the interface definition early for comments.
> 
> I wonder how many people will comment it without seeing usage example.

It is my hope that Mellanox will contribute to this and use it for
ipoib - we've have had conversations along these lines in the
past... Apparently mlx4/5 could run quite a bit faster if used like
this.

Jason
