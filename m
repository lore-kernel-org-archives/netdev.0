From: "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 06/11] sigwd93: switch to dma_alloc_attrs
Date: Mon, 26 Jun 2017 14:20:51 -0400
Message-ID: <yq1inji3918.fsf@oracle.com>
References: <20170616071716.17321-1-hch@lst.de>
        <20170616071716.17321-7-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-serial-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-metag-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        nios2-dev-g9ZBwUv/Ih/yUk5EbOjzuce+I+R0W71w@public.gmane.org, linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Return-path: <linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170616071716.17321-7-hch-jcswGhMUV9g@public.gmane.org> (Christoph Hellwig's message
        of "Fri, 16 Jun 2017 09:17:11 +0200")
Sender: linux-metag-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Christoph,

> Use dma_alloc_attrs directly instead of the dma_alloc_noncoherent
> wrapper.

Fixed driver name typo and applied to 4.13/scsi-queue.

-- 
Martin K. Petersen	Oracle Linux Engineering
