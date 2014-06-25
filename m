From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 00/22] Add and use pci_zalloc_consistent
Date: Wed, 25 Jun 2014 15:41:12 -0400
Message-ID: <20140625194112.GJ3445@tuxdriver.com>
References: <cover.1403530604.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	iss_storagedev@hp.com, linux-crypto@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-eata@i-connect.net,
	devel@driverdev.osuosl.org, linux-arch@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1403530604.git.joe@perches.com>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 23, 2014 at 06:41:28AM -0700, Joe Perches wrote:
> Adding the helper reduces object code size as well as overall
> source size line count.
> 
> It's also consistent with all the various zalloc mechanisms
> in the kernel.
> 
> Done with a simple cocci script and some typing.
> 
> Joe Perches (22):

>   ipw2100: Use pci_zalloc_consistent
>   mwl8k: Use pci_zalloc_consistent
>   rtl818x: Use pci_zalloc_consistent
>   rtlwifi: Use pci_zalloc_consistent

Sure, fine by me.

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
