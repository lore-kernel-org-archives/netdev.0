From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] cxgb3 - sge page management
Date: Wed, 13 Jun 2007 15:46:10 -0400
Message-ID: <46704982.5000603@garzik.org>
References: <20070531041047.6117.53202.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759919AbXFMTqc@vger.kernel.org>
In-Reply-To: <20070531041047.6117.53202.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> Streamline sge page management.
> Fix dma mappings when buffers are recycled.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/cxgb3/adapter.h |   38 ++--
>  drivers/net/cxgb3/sge.c     |  423 ++++++++++++++++++++++---------------------
>  2 files changed, 232 insertions(+), 229 deletions(-)

applied 1-3 to #upstream (2.6.23)
