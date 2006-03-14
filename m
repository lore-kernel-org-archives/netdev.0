From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH 1/8] [I/OAT] DMA memcpy subsystem
Date: Tue, 14 Mar 2006 23:13:36 +0100
Message-ID: <20060314221336.GB2269@elf.ucw.cz>
References: <20060311022759.3950.58788.stgit@gitlost.site> <20060311022919.3950.43835.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964797AbWCNWNr@vger.kernel.org>
To: Chris Leech <christopher.leech@intel.com>
Content-Disposition: inline
In-Reply-To: <20060311022919.3950.43835.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> --- /dev/null
> +++ b/drivers/dma/dmaengine.c
> @@ -0,0 +1,360 @@
> +/*****************************************************************************
> +Copyright(c) 2004 - 2006 Intel Corporation. All rights reserved.
> +
> +This program is free software; you can redistribute it and/or modify it
> +under the terms of the GNU General Public License as published by the Free
> +Software Foundation; either version 2 of the License, or (at your option)
> +any later version.
> +
> +This program is distributed in the hope that it will be useful, but WITHOUT
> +ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> +FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> +more details.
> +
> +You should have received a copy of the GNU General Public License along with
> +this program; if not, write to the Free Software Foundation, Inc., 59
> +Temple Place - Suite 330, Boston, MA  02111-1307, USA.
> +
> +The full GNU General Public License is included in this distribution in the
> +file called LICENSE.
> +*****************************************************************************/


Could you use 
/*
 *
 */

comment style, and describe in one or two lines what the source does
in the header?

								Pavel
-- 
209:using System.IO;
