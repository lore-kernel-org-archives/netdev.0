From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] drivers/base: export gpl (un)register_memory_notifier
Date: Mon, 11 Feb 2008 17:02:11 +0100
Message-ID: <20080211160211.GA22139@uranus.ravnborg.org>
References: <200802111657.07534.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Hansen <haveblue@us.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>,
	Thomas Klein <osstklei@de.ibm.com>,
	"Themann, Jan-Bernd" <themann@de.ibm.com>,
	Greg KH <greg@kroah.com>, Christoph Raisch <RAISCH@de.ibm.com>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:39590 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754697AbYBKQCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 11:02:04 -0500
Content-Disposition: inline
In-Reply-To: <200802111657.07534.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 11, 2008 at 04:57:06PM +0100, Jan-Bernd Themann wrote:
> Drivers like eHEA need memory notifiers in order to 
> update their internal DMA memory map when memory is added
> to or removed from the system.

Can you please add proper kernel-doc formatted comments
when you export a symbol so others can get a clue
what the exported function is supposed to do.

	Sam
