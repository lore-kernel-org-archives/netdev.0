From: Grant Likely <grant.likely@linaro.org>
Subject: Re: [PATCH 22/51] DMA-API: amba: get rid of separate dma_mask
Date: Sun, 22 Sep 2013 07:18:28 -0500
Message-ID: <20130922121828.58F02C42373@trevor.secretlab.ca>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
 <E1VMm3x-0007hp-Lv@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <rob.herring@calxeda.com>
To: Russell King <rmk+kernel@arm.linux.org.uk>, alsa-devel@alsa-project.org,
 b43-dev@lists.infradead.org, devel@driverdev.osuosl.org,
 devicetree@vger.kernel.org, dri-devel@lists.freedesktop.org,
 e1000-devel@lists.sourceforge.net, linux-arm-kernel@lists.infradead.org,
 linux-crypto@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-fbdev@vger.kernel.org, linux-ide@vger.kernel.org,
 linux-media@vger.kernel.org, linux-mmc@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-omap@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-samsung-soc@vger.kernel.org,
 linux-scsi@vger.kernel.org, linux-tegra@vger.kernel.org,
 linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
 netdev@vger.kernel.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 uclinux-dist-devel@blackfin.uclinux.org
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <E1VMm3x-0007hp-Lv@rmk-PC.arm.linux.org.uk>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

On Thu, 19 Sep 2013 22:47:01 +0100, Russell King <rmk+kernel@arm.linux.org.uk> wrote:
> AMBA Primecell devices always treat streaming and coherent DMA exactly
> the same, so there's no point in having the masks separated.
> 
> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

for the drivers/of/platform.c portion:
Acked-by: Grant Likely <grant.likely@linaro.org>

g.
