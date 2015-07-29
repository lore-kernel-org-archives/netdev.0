From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] igb/ixgbe: Fix ordering of SR-IOV teardown
Date: Wed, 29 Jul 2015 14:31:41 -0700 (PDT)
Message-ID: <20150729.143141.657802657776347202.davem@davemloft.net>
References: <20150727223753.10121.78169.stgit@gimli.home>
	<20150729.121630.2264285348757503000.davem@davemloft.net>
	<1438198387.13460.68.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: alex.williamson@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438198387.13460.68.camel@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex Williamson <alex.williamson@redhat.com>
Date: Wed, 29 Jul 2015 13:33:07 -0600

> I expect that's because of this patch that's in Jeff's dev-queue branch:
> 
> http://git.kernel.org/cgit/linux/kernel/git/jkirsher/next-queue.git/commit/?h=dev-queue&id=ddf766a812a13eca1116b5905e902184904266f9
> 
> I based these patches off that branch, assuming they'd take the same
> route and avoid the merge conflict.  If you'd rather take these, I'll be
> happy to respin.  Apologies for not noting the base branch in the
> series.  Thanks,

No, that's fine, this would normally go via Jeff's tree anyways.

I just didn't see him take it so I assumed that it should go via me.
