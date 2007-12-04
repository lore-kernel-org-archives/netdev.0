From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] cxgb - revert file mode changes.
Date: Tue, 04 Dec 2007 14:54:00 -0500
Message-ID: <4755B058.7070402@garzik.org>
References: <20071201235717.22418.24800.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754026AbXLDTyY@vger.kernel.org>
In-Reply-To: <20071201235717.22418.24800.stgit@speedy5>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> revert inavertant file mode changes
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>
> ---
> 
>  drivers/net/chelsio/cxgb2.c  |    0 
>  drivers/net/chelsio/pm3393.c |    0 
>  drivers/net/chelsio/sge.c    |    0 
>  drivers/net/chelsio/sge.h    |    0 
>  4 files changed, 0 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
> old mode 100755
> new mode 100644
> diff --git a/drivers/net/chelsio/pm3393.c b/drivers/net/chelsio/pm3393.c
> old mode 100755
> new mode 100644
> diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
> old mode 100755
> new mode 100644
> diff --git a/drivers/net/chelsio/sge.h b/drivers/net/chelsio/sge.h
> old mode 100755
> new mode 100644

applied #upstream-fixes


