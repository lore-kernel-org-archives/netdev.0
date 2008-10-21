From: Bill Gatliff <bgat@billgatliff.com>
Subject: Re: [PATCH 14/16] RealView: Use the in-kernel smc911x.c driver on
	RealView
Date: Tue, 21 Oct 2008 08:27:44 -0500
Message-ID: <48FDD8D0.1060400@billgatliff.com>
References: <OF6B543A5F.032D7BBC-ON802574E9.00340E58-802574E9.00396C6E@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Guennadi Liakhovetski <g.liakhovetski@gmx.de>,
	linux-arm-kernel@lists.arm.linux.org.uk, Ian.Saturley@smsc.com,
	netdev@vger.kernel.org
To: Steve.Glendinning@smsc.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.arm.linux.org.uk>
In-Reply-To: <OF6B543A5F.032D7BBC-ON802574E9.00340E58-802574E9.00396C6E@smsc.com>
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

Steve.Glendinning@smsc.com wrote:

> * I do have a patch to add DMA support to smsc911x, but it's
> platform-specific to sh.  I haven't added pxa dma support only because I
> don't have a suitable pxa platform available.

I have several PXA platforms with SMSC chips.  Let me know off-list if I can
help in any way.


b.g.
-- 
Bill Gatliff
bgat@billgatliff.com

-------------------------------------------------------------------
List admin: http://lists.arm.linux.org.uk/mailman/listinfo/linux-arm-kernel
FAQ:        http://www.arm.linux.org.uk/mailinglists/faq.php
Etiquette:  http://www.arm.linux.org.uk/mailinglists/etiquette.php
