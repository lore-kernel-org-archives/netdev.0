From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 21/37] drivers/ata: use .dev.of_node
 instead of .node in struct of_device
Date: Thu, 11 Mar 2010 10:38:36 -0800 (PST)
Message-ID: <20100311.103836.13755632.davem@davemloft.net>
References: <20100311174830.4824.19820.stgit@angua>
	<20100311180543.4824.70491.stgit@angua>
	<4B9936F2.3020105@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, gregkh@suse.de, benh@kernel.crashing.org,
	grant.likely@secretlab.ca, linux-ide@vger.kernel.org,
	linux-i2c@vger.kernel.org, sparclinux@vger.kernel.org,
	jeremy.kerr@canonical.com, sfr@canb.auug.org.au,
	linux-scsi@vger.kernel.org, jgarzik@pobox.com,
	microblaze-uclinux@itee.uq.edu.au,
	devicetree-discuss@lists.ozlabs.org, James.Bottomley@suse.de,
	ben-linux@fluff.org, monstr@monstr.eu, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, broonie@opensource.wolfsonmicro.com,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	dwmw2@infradead.org
To: sshtylyov@mvista.com
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <4B9936F2.3020105@ru.mvista.com>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
	<mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Sender: alsa-devel-bounces@alsa-project.org
Errors-To: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sshtylyov@mvista.com>
Date: Thu, 11 Mar 2010 21:31:14 +0300

>   Should probably have been 2 patches instead of one, as drivers/ata/
>   and drivers/ide/ are different subsystems...

No, he should consolidate these changes _MORE_ not less.

The patch set is already too large to review at it is!
