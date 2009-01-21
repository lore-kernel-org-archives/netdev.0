From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] bnx2x: remove a few trivial macros
Date: Wed, 21 Jan 2009 15:42:46 -0800 (PST)
Message-ID: <20090121.154246.183468953.davem@davemloft.net>
References: <1232517046.9701.19.camel@brick>
	<1232522093.29087.9.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, netdev@vger.kernel.org
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51563
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753859AbZAUXmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 18:42:44 -0500
In-Reply-To: <1232522093.29087.9.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 21 Jan 2009 09:14:53 +0200

> On Tue, 2009-01-20 at 21:50 -0800, Harvey Harrison wrote:
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > ---
> > Eilon, after this series, sparse with endian-checking at least gets through a
> > compile without hitting too many errors, patch 9 is a functional change
> > and may have exposed an endian bug in the driver....but I had to get through
> > the other 8 to see it ;-)
> > 
> Wooh!!! Harvey - thanks for all the hard work!
> 
> I will review it carefully and start regression tests on few different
> platforms to verify this fix. Stay tuned.

Thanks Eilon, once you've validated these changes let me know
so I can add them to net-next-2.6
