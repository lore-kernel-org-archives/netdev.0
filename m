From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] e1000: add forgotten PCI ID for supported device
Date: Fri, 28 Jul 2006 16:18:37 -0700
Message-ID: <20060728231837.GA2109@kroah.com>
References: <44CA8A59.40002@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, NetDev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kroah.org ([69.55.234.183]:28592 "EHLO perch.kroah.org")
	by vger.kernel.org with ESMTP id S1161371AbWG1Xuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 19:50:39 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
Content-Disposition: inline
In-Reply-To: <44CA8A59.40002@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 03:06:17PM -0700, Auke Kok wrote:
> 
> The Intel(R) PRO/1000 82572EI card is fully supported by 7.0.33-k2 and 
> onward. Add the device ID so this card works with 2.6.17.y onward. This 
> device ID was accidentally omitted.

Sorry, but we don't add new device support in the -stable kernel tree,
it's "bugfixes only."

thanks,

greg k-h
