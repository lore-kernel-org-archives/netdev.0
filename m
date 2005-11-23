From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RFC] [PATCH 0/3] ioat: DMA engine support
Date: Wed, 23 Nov 2005 17:53:59 -0500
Message-ID: <4384F307.6040904@pobox.com>
References: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, christopher.leech@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030466AbVKWWyM@vger.kernel.org>
To: Andrew Grover <andrew.grover@intel.com>
In-Reply-To: <Pine.LNX.4.44.0511231143380.32487-100000@isotope.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Grover wrote:
> overall diffstat information:
>  drivers/Kconfig           |    2 
>  drivers/Makefile          |    1 
>  drivers/dma/Kconfig       |   40 ++
>  drivers/dma/Makefile      |    5 
>  drivers/dma/cb_list.h     |   12 
>  drivers/dma/dmaengine.c   |  394 ++++++++++++++++++++++++
>  drivers/dma/testclient.c  |  132 ++++++++
>  include/linux/dmaengine.h |  268 ++++++++++++++++
>  net/core/Makefile         |    3 
>  net/core/dev.c            |   78 ++++
>  net/core/user_dma.c       |  422 ++++++++++++++++++++++++++
>  11 files changed, 1356 insertions(+), 1 deletion(-)


overall, there was a distinction lack of any useful 
description/documentation, over and above the code itself.

	Jeff
