From: James Morris <jmorris@namei.org>
Subject: Re: TCP stalls in current git, possibly splice related
Date: Fri, 13 Jul 2007 08:23:59 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0707130823490.17942@d.namei>
References: <Line.LNX.4.64.0707121608100.10773@d.namei>
 <1184320965.30334.2.camel@johannes.berg> <20070713110534.GF5328@kernel.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:44141 "EHLO
	mail2.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756765AbXGMMYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 08:24:04 -0400
In-Reply-To: <20070713110534.GF5328@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Jul 2007, Jens Axboe wrote:

> On Fri, Jul 13 2007, Johannes Berg wrote:
> > On Thu, 2007-07-12 at 16:12 -0400, James Morris wrote:
> > > I'm seeing TCP connection stalls with current git, and a bisect found the 
> > > following as a possible cause:
> > 
> > I'm also seeing stalls with synergy.
> 
> Please try the below.

Works for me.

-- 
James Morris
<jmorris@namei.org>
