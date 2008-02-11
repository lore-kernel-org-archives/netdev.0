From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Mon, 11 Feb 2008 08:04:43 -0800
Message-ID: <1202745883.8276.5.camel@nimitz.home.sr71.net>
References: <200802111657.07534.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Thomas Klein <osstklei@de.ibm.com>,
	"Themann, Jan-Bernd" <themann@de.ibm.com>,
	Greg KH <greg@kroah.com>, Christoph Raisch <RAISCH@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758235AbYBKQE5@vger.kernel.org>
In-Reply-To: <200802111657.07534.ossthema@de.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2008-02-11 at 16:57 +0100, Jan-Bernd Themann wrote:
> Drivers like eHEA need memory notifiers in order to 
> update their internal DMA memory map when memory is added
> to or removed from the system.

Could you post this with the new users as well so we can make sure
they're not abusing this in some way?

-- Dave
