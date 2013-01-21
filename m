From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: PMTU discovery is broken on kernel 3.7.1 for UDP sockets
Date: Mon, 21 Jan 2013 12:38:50 +0100
Message-ID: <20130121113850.GD30530@secunet.com>
References: <1355924119.2676.6.camel@bwh-desktop.uk.solarflarecom.com>
 <50D1CECE.7090706@oktetlabs.ru>
 <1355945864.2676.21.camel@bwh-desktop.uk.solarflarecom.com>
 <20121220073445.GM18940@secunet.com>
 <50D2F4E5.4050904@oktetlabs.ru>
 <20121220123535.GN18940@secunet.com>
 <20121221102253.GO18940@secunet.com>
 <50F3C153.9030204@oktetlabs.ru>
 <20130118081145.GB24987@secunet.com>
 <50FD2708.6060906@oktetlabs.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	"Alexandra N. Kossovsky" <Alexandra.Kossovsky@oktetlabs.ru>
To: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:46871 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752544Ab3AULix convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 06:38:53 -0500
Content-Disposition: inline
In-Reply-To: <50FD2708.6060906@oktetlabs.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2013 at 03:31:20PM +0400, Yurij M. Plotnikov wrote:
> On 01/18/13 12:11, Steffen Klassert wrote:
> >
> >I'll send three patches in reply to this mail. Applying patch one and two
> >should fix the bug you reported. If you use IPsec you need patch three too.
> >The patches are marked as RFC, I'll do proper patch submission if you can
> >confirm that they fix this bug.
> Sorry for long delay. I've just checked patches 1+2 and they fix the
> bug for me.
> 

Thanks a lot for reporting and testing!
