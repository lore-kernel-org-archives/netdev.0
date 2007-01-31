From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/10] cxgb3 - FW versioning
Date: Wed, 31 Jan 2007 07:51:30 -0500
Message-ID: <45C090D2.4060302@garzik.org>
References: <20070131034345.8574.21031.stgit@localhost.localdomain> <45C07202.3090308@garzik.org> <20070131124437.GA26476@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Christoph Hellwig <hch@infradead.org>,
	Jeff Garzik <jeff@garzik.org>, Divy Le Ray <None@chelsio.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56541 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933204AbXAaMvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 07:51:43 -0500
In-Reply-To: <20070131124437.GA26476@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Hellwig wrote:
> On Wed, Jan 31, 2007 at 05:40:02AM -0500, Jeff Garzik wrote:
>> honestly it looks like just about every ioctl except load-firmware should go
> 
> And while we're at it a load-firmware sounds like a nice addition for
> ethtool aswell.  Or we may want to extent the firmware loader to deal with
> updating firmware in addition to loading it to rom-less devices.

Agreed.

	Jeff



