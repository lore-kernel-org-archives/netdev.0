From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][BNX2X] round three
Date: Fri, 12 Oct 2007 15:03:41 -0700 (PDT)
Message-ID: <20071012.150341.41635825.davem@davemloft.net>
References: <1192038559.29746.127.camel@eliezer>
	<p73641c4cfz.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eliezert@broadcom.com, netdev@vger.kernel.org, jeff@garzik.org,
	mchan@broadcom.com
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55823
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758453AbXJLWDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 18:03:41 -0400
In-Reply-To: <p73641c4cfz.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <andi@firstfloor.org>
Date: Fri, 12 Oct 2007 16:47:28 +0200

> "Eliezer Tamir" <eliezert@broadcom.com> writes:
> 
> 
> > * For now depend on x86 or x86_64, will add more architectures ASAP.
> 
> Why is that? Linux drivers normally should not be architecture specific.

I totally agree, and the only way to weed out these kinds of
bugs is to allow it to build on other systems so users can
try it out and report what fails.  Or even better, a motivated
developer tries it out and fixes the bugs for you :-)
