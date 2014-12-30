From: "hch@infradead.org" <hch@infradead.org>
Subject: Re: [scsi/net-next]Pull csiostor from net-next
Date: Tue, 30 Dec 2014 01:36:08 -0800
Message-ID: <20141230093608.GA13711@infradead.org>
References: <24C222ADD7729F4FB5113B41FF0028A1BCB65F@nice.asicdesigners.com>
 <20141227145956.GB1094@infradead.org>
 <20141227150917.GA16964@infradead.org>
 <24C222ADD7729F4FB5113B41FF0028A1BCC18E@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Praveen Madhavan <praveenm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:55891 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbaL3JgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2014 04:36:09 -0500
Content-Disposition: inline
In-Reply-To: <24C222ADD7729F4FB5113B41FF0028A1BCC18E@nice.asicdesigners.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 28, 2014 at 03:13:14PM +0000, Praveen Madhavan wrote:
> > How much do you plan to send for the 3.20 window?  I'd rather avoid
> > having to pull in the net-next tree and merge everything through Dave
> > if that seems feasible.
> I hv couple of patches fixes for 3.20 window. Can you please pull from linux-next tree ?

If it's really just a few fixes I'd prefer to just ACK them on the scsi
list and send them through the net tree to avoid a cross dependency.
