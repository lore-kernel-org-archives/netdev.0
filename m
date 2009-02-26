From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tehuti: Use request_firmware()
Date: Wed, 25 Feb 2009 21:31:14 -0800 (PST)
Message-ID: <20090225.213114.227259583.davem@davemloft.net>
References: <1235324041.2832.45.camel@hashbaz.i.decadent.org.uk>
	<20090225.000809.74281540.davem@davemloft.net>
	<1235619983.8683.16.camel@hashbaz.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, baum@tehutinetworks.net, andy@greyhouse.net
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751524AbZBZFbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 00:31:31 -0500
In-Reply-To: <1235619983.8683.16.camel@hashbaz.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Thu, 26 Feb 2009 03:46:23 +0000

> On Wed, 2009-02-25 at 00:08 -0800, David Miller wrote:
> > Ben your two patches are HTML damanged, I see "=20" sequences
> > all over the place.  That could be my mailer, but...
> 
> I just tested with both mutt and Evolution, and they use quoted-
> printable for the body of signed messages (perhaps to avoid the risk of
> whitespace loss invalidating the signature).  So I suppose I'll have to
> leave patches unsigned.  Which sucks, frankly.

I don't care about the body, I can work around the commit
message text, it's just the patch.

Make it a binary attachment, surely mutt and Crapolution let
you do that?
