From: Honggang LI <honli@redhat.com>
Subject: Re: [PATCH linux-next v3] mlx5: wrong page mask if
 CONFIG_ARCH_DMA_ADDR_T_64BIT enabled for 32Bit architectures
Date: Wed, 15 Apr 2015 15:14:33 +0800
Message-ID: <20150415071433.GB4514@honli.nay.redhat.com>
References: <1429067957-9148-1-git-send-email-honli@redhat.com>
 <552DF6BB.5040005@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eli@mellanox.com, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <552DF6BB.5040005@mellanox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2015 at 08:27:23AM +0300, Or Gerlitz wrote:
> On 4/15/2015 6:19 AM, Honggang Li wrote:
> >Fix(bf0bf77 mlx5: Support communicating arbitrary host page size to firmware)
> 
> This isn't the way to write the fix note, do it that way
> 
> Fixes: bf0bf77f6519 ('mlx5: Support communicating arbitrary host
> page size to firmware')
> 

Fixed it and new patch (v4) had been sent out. Please review it. Hope it
is the final one.

thanks

> >
> >Signed-off-by: Honggang Li<honli@redhat.com>
> 
