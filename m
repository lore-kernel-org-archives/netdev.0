From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 12/37] drivers/usb: use .dev.of_node instead of .node
	in struct of_device
Date: Thu, 11 Mar 2010 10:28:22 -0800
Message-ID: <20100311182822.GA1950@suse.de>
References: <20100311174830.4824.19820.stgit@angua> <20100311180453.4824.61269.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: monstr@monstr.eu, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infradead.org, jeremy.kerr@canonical.com,
	James.Bottomley@suse.de, broonie@opensource.wolfsonmicro.com,
	microblaze-uclinux@itee.uq.edu.au, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org,
	linux-ide@vger.kernel.org, netdev@vger.kernel.org,
	linux-i2c@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-scsi@vger.kernel.org, alsa-devel@alsa-project.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100311180453.4824.61269.stgit@angua>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 11, 2010 at 11:04:54AM -0700, Grant Likely wrote:
> .node is being removed
> 
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>

Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
