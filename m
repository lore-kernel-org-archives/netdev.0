From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] pasemi_mac: Don't set replace-source-address
	descriptor bits
Date: Thu, 8 Nov 2007 12:47:34 -0500
Message-ID: <20071108174734.GC3011@havoc.gtf.org>
References: <20071107042001.GC22637@lixom.net> <20071107042039.GD22637@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:42066 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760064AbXKHRrf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 12:47:35 -0500
Content-Disposition: inline
In-Reply-To: <20071107042039.GD22637@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 06, 2007 at 10:20:39PM -0600, Olof Johansson wrote:
> Don't use the "replace source address with local MAC address" bits, since
> it causes problems on some variations of the hardware due to an erratum.
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>

applied 1-2


