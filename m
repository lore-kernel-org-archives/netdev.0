From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 1/8] [I/OAT] DMA memcpy subsystem
Date: Sat, 11 Mar 2006 00:53:16 -0800
Message-ID: <20060311005316.61368bac.akpm@osdl.org>
References: <20060311022759.3950.58788.stgit@gitlost.site>
	<20060311022919.3950.43835.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932434AbWCKIz0@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
In-Reply-To: <20060311022919.3950.43835.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Leech <christopher.leech@intel.com> wrote:
>
> +void dma_async_device_cleanup(struct kref *kref);
>

Declarations go in header files, please.  Or give it static scope.
