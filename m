From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2][NETLABEL]: Shrink the genl-ops registration code.
Date: Sun, 17 Feb 2008 22:33:25 -0800 (PST)
Message-ID: <20080217.223325.190655583.davem@davemloft.net>
References: <47B2CFF8.50803@openvz.org>
	<200802130833.09096.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50984
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752400AbYBRGcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 01:32:48 -0500
In-Reply-To: <200802130833.09096.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Wed, 13 Feb 2008 08:33:08 -0500

> On Wednesday 13 February 2008 6:09:44 am Pavel Emelyanov wrote:
> > Turning them to array and registration in a loop saves
> > 80 lines of code and ~300 bytes from text section.
> >
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Definitely an improvement, thank you.
> 
> Acked-by: Paul Moore <paul.moore@hp.com>

Applied.
