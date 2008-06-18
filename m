From: jes@trained-monkey.org (Jes Sorensen)
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Wed, 18 Jun 2008 12:52:03 -0400
Message-ID: <18521.15667.750124.266264@jaguar.mkp.net>
References: <1213608300.26255.665.camel@pmac.infradead.org>
	<4856CE43.4020706@garzik.org>
	<1213652749.26255.842.camel@pmac.infradead.org>
	<4856E50C.5050908@garzik.org>
	<1213699220.26255.977.camel@pmac.infradead.org>
	<1213805681.26255.1312.camel@pmac.infradead.org>
	<4859371F.8090404@garzik.org>
	<1213807439.26255.1327.camel@pmac.infradead.org>
	<1213807525.26255.1331.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	jaswinder@infradead.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jaguar.mkp.net ([192.139.46.146]:54026 "EHLO jaguar.mkp.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752518AbYFRQwF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 12:52:05 -0400
In-Reply-To: <1213807525.26255.1331.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "David" == David Woodhouse <dwmw2@infradead.org> writes:

David> On Wed, 2008-06-18 at 17:44 +0100, David Woodhouse wrote:
>> In the patch I just sent, you can see exactly what's changing. Now,
>> just for fun, let's try splitting it into two pointlessly separate
>> patches as you seem to want.
>> 
>> First we add the 'new' code path...

David> ... and then we remove the old...

I'm good with either of these two models - single or dual patch
revision. You can throw in an Acked-by: Jes Sorensen <jes@sgi.com> if
you like.


Cheers,
Jes
