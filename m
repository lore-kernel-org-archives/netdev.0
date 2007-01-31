From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/10] cxgb3 - FW versioning
Date: Wed, 31 Jan 2007 12:44:37 +0000
Message-ID: <20070131124437.GA26476@infradead.org>
References: <20070131034345.8574.21031.stgit@localhost.localdomain> <45C07202.3090308@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Divy Le Ray <None@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:49502 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933174AbXAaMoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 07:44:55 -0500
Content-Disposition: inline
In-Reply-To: <45C07202.3090308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 31, 2007 at 05:40:02AM -0500, Jeff Garzik wrote:
> honestly it looks like just about every ioctl except load-firmware should go

And while we're at it a load-firmware sounds like a nice addition for
ethtool aswell.  Or we may want to extent the firmware loader to deal with
updating firmware in addition to loading it to rom-less devices.

