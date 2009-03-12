From: "Mike (mwester)" <mwester@dls.net>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 15:24:20 -0500
Message-ID: <49B96F74.50804@dls.net>
References: <49B82566.3070909@weinigel.se>
	<20090311171354.04c7a63d@nehalam>	<49B8E6D4.2030702@weinigel.se>	<20090312.055523.193191701.davem@davemloft.net>	<49B91A7B.7050303@weinigel.se>
	<20090312151211.GB24995@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christer Weinigel <christer@weinigel.se>,
	David Miller <davem@davemloft.net>,
	shemminger@vyatta.com, s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <20090312151211.GB24995@hmsreliant.think-freely.org>
List-Unsubscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=unsubscribe>
List-Archive: <http://lists.arm.linux.org.uk/lurker/list/linux-arm-kernel.html>
List-Post: <mailto:linux-arm-kernel@lists.arm.linux.org.uk>
List-Help: <mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=help>
List-Subscribe: <http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.arm.linux.org.uk?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.arm.linux.org.uk
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk
List-Id: netdev.vger.kernel.org

Neil Horman wrote:

> What exactly is so difficult about cpio-ing up an initramfs to do this work with
> sed and ifconfig? You make it sound like its an impossible barrier. Its really
> quite simple

Can you share your scripts and tools for creating an initramfs so
easily?  I too run into this problem -- I've always used the
kernel-provided mechanism to DHCP and do the nfs mount of the rootfs,
but if the initramfs is the right way to do that, then I'll be happy to
change.

It always looked rather daunting to me, and a lot of extra effort
compared to letting the kernel do the job, but if it really is so easy,
then I'll be happy to change my practices.

Thanks!
Mike (mwester)

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
