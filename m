From: "David Mack" <dmack@juniper.net>
Subject: RE: e100 problems in .23rc8 ?
Date: Tue, 16 Oct 2007 09:39:48 -0700
Message-ID: <7DCDA0F058071B49AED9D3D7886C41BE0A43AE88@muon.jnpr.net>
References: <E1IgWqn-0000iU-00@gondolin.me.apana.org.au> <4714CBAB.4090601@redhat.com> <20071016143505.GA12640@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davej@redhat.com>, <auke-jan.h.kok@intel.com>,
	<netdev@vger.kernel.org>
To: "Herbert Xu" <herbert.xu@redhat.com>,
	"Eric Sandeen" <sandeen@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og105.obsmtp.com ([64.18.2.163]:58343 "EHLO
	exprod7og105.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbXJPQkz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 12:40:55 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20071016143505.GA12640@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

My problem is anything but sporadic. I have succeeded in booting a
2.6.23-based kernel exactly once since the roll toward F8 started early
last summer.

Dave

> -----Original Message-----
> From: Herbert Xu [mailto:herbert@gondor.apana.org.au] On 
> Behalf Of Herbert Xu
> Sent: Tuesday, October 16, 2007 7:35 AM
> To: Eric Sandeen
> Cc: David Mack; davej@redhat.com; auke-jan.h.kok@intel.com; 
> netdev@vger.kernel.org
> Subject: Re: e100 problems in .23rc8 ?
> 
> On Tue, Oct 16, 2007 at 09:33:15AM -0500, Eric Sandeen wrote:
> > 
> > Hm... running 2.6.23-6.fc8, I've been through 30+ reboot 
> cycles without
> > a problem.  Before, I'd oops every 5 or so times I booted...
> > 
> > I now have another NIC in the box, disabled; I don't think 
> that should
> > be affecting anything?
> 
> Well the original problem was caused by spurious interrupts on
> the IRQ line where your e100 is so it could well be sporadic.
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> 
