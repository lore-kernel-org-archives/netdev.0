From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH] Support DMA-API debugging facility on PowerPC
Date: Wed, 1 Jul 2009 20:34:44 +0200
Message-ID: <20090701183444.GI4182@8bytes.org>
References: <1227284770-19215-1-git-send-email-joerg.roedel@amd.com> <1227286492.4901.208.camel@macbook.infradead.org> <20081121165722.GD1386@amd.com> <1227287215.4901.213.camel@macbook.infradead.org> <20081121171802.GK733@elte.hu> <20081121172046.GF1386@amd.com> <1227288269.4901.222.camel@macbook.infradead.org> <20081121172722.GG1386@amd.com> <1233873842.8135.6.camel@macbook.infradead.org> <1246454380.3681.1634.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, benh@kernel.crashing.org,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755888AbZGASex@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1246454380.3681.1634.camel@macbook.infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 01, 2009 at 02:19:40PM +0100, David Woodhouse wrote:
> 
> Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
> Tested-by: Johannes Berg <johannes@sipsolutions.net>

Acked-by: Joerg Roedel <joerg.roedel@amd.com>

Great stuff. You may also consider registering the powerpc io buses to
dma-api debug. Then you get the driver memory leak functionality too.

Joerg
