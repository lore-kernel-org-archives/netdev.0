From: Alexander Schmidt <alexs@linux.vnet.ibm.com>
Subject: Re: [PATCH 25/37] drivers/infiniband: use .dev.of_node instead of
 .node in struct of_device
Date: Fri, 12 Mar 2010 14:30:22 +0100
Message-ID: <20100312143022.18b954a5@alex-laptop>
References: <20100311174830.4824.19820.stgit@angua>
	<20100311180605.4824.3613.stgit@angua>
	<adavdd2d41q.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	alsa-devel@alsa-project.org, broonie@opensource.wolfsonmicro.com,
	linux-ide@vger.kernel.org, James.Bottomley@suse.de,
	linux-i2c@vger.kernel.org, sparclinux@vger.kernel.org,
	jeremy.kerr@canonical.com, sfr@canb.auug.org.au,
	linux-scsi@vger.kernel.org, jgarzik@pobox.com,
	microblaze-uclinux@itee.uq.edu.au,
	devicetree-discuss@lists.ozlabs.org,
	Christoph Raisch <raisch@de.ibm.com>, ben-linux@fluff.org,
	monstr@monstr.eu, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	gregkh@suse.de, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, dwmw2@infradead.org, davem@davemloft.net
To: Roland Dreier <rdreier@cisco.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <adavdd2d41q.fsf@roland-alpha.cisco.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 11 Mar 2010 11:57:53 -0800
Roland Dreier <rdreier@cisco.com> wrote:

> Seems fine... adding EHCA guys just to make sure.
> 
>  > .node is being removed
>  > 
>  > Signed-off-by: Grant Likely <grant.likely@secretlab.ca>

Acked-by: Alexander Schmidt <alexs@linux.vnet.ibm.com>
