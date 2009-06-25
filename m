From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH 12/19] drivers/net: Use PCI_VDEVICE
Date: Thu, 25 Jun 2009 00:19:06 -0600
Message-ID: <20090625061906.GB18519@lackof.org>
References: <cover.1245906151.git.joe@perches.com> <f746d5c571120f930fb6bb50d8303766573f927d.1245906152.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Divy Le Ray <divy@chelsio.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Tim Hockin <thockin@hockin.org>,
	Daniele Venzano <venza@brownhat.org>,
	Jens Osterkamp <jens@de.ibm.com>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	Ion Badulescu <ionut@cs.columbia.edu>,
	Andy Gospodarek <andy@greyhouse.net>,
	Alexander Indenbaum <baum@tehutinetworks.net>,
	Samuel Chessman <chessman@tux.org>,
	Kyle McMartin <kyle@mcmartin.ca>,
	Grant Grundler <grundler@parisc-linux.org>,
	David Dillow <dave@thedillows.org>, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:47876 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753000AbZFYGTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 02:19:04 -0400
Content-Disposition: inline
In-Reply-To: <f746d5c571120f930fb6bb50d8303766573f927d.1245906152.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 24, 2009 at 10:13:28PM -0700, Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  drivers/net/tulip/de2104x.c       |    6 +--
>  drivers/net/tulip/de4x5.c         |   12 ++---
>  drivers/net/tulip/tulip_core.c    |   28 ++++++------
>  drivers/net/tulip/uli526x.c       |    4 +-
>  drivers/net/tulip/winbond-840.c   |    4 +-

Tulip bits look fine.

Acked-by: Grant Grundler <grundler@parisc-linux.org>

thanks,
grant
