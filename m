From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RESEND PATCH 1/3] e1000e: set CONFIG_E1000E=y in x86
	defconfigs
Date: Mon, 23 Jun 2008 13:26:18 +0200
Message-ID: <20080623112618.GC7485@elte.hu>
References: <20080622221916.5907.79563.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757090AbYFWL0v@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080622221916.5907.79563.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Auke Kok <auke-jan.h.kok@intel.com>
> 
> This adds to the already default CONFIG_E1000=y in these files.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
> 
>  arch/x86/configs/i386_defconfig   |    1 +
>  arch/x86/configs/x86_64_defconfig |    1 +

that is not an e1000 patch but an arch/x86 defconfig patch. NAK on this 
route of patch propagation.

	Ingo
