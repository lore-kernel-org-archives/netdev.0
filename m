From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] [ISDN] Documentation patchset
Date: Mon, 27 Apr 2009 18:14:19 -0700 (PDT)
Message-ID: <20090427.181419.47244869.davem@davemloft.net>
References: <200904271345.35345.karsten-keil@t-online.de>
	<20090427.053902.262806706.davem@davemloft.net>
	<200904271513.32728.karsten-keil@t-online.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: karsten-keil@t-online.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43020
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757080AbZD1BO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 21:14:26 -0400
In-Reply-To: <200904271513.32728.karsten-keil@t-online.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <karsten-keil@t-online.de>
Date: Mon, 27 Apr 2009 15:13:32 +0200

> I can leave out the date field, but if I resend  patch from a other developer 
> (which I signed or acked as maintainer), I need to move the original From into 
> the body, my uplink rewrites the From with my address. Would this be still OK 
> or does the From in the body make also problems with patchwork ?

Yes, it's perfectly fine to put the author's From: field in
the body.  And as the patch submitter your should preserve
your From: in the normal email headers.  That's how it's
supposed to be :-)
