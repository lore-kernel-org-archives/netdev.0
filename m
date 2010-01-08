From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: tg3 appears to be sick in 2.6.33
Date: Fri, 8 Jan 2010 14:50:25 -0800
Message-ID: <20100108225024.GB22950@core.coreip.homeip.net>
References: <201001071156.31892.dmitry.torokhov@gmail.com>
 <20100108013600.GA2711@core.coreip.homeip.net>
 <20100108180915.GA8218@xw6200.broadcom.net>
 <201001081025.50298.dmitry.torokhov@gmail.com>
 <20100108194222.GA8386@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	jfeeney@redhat.com
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.216.174]:41368 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957Ab0AHWum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2010 17:50:42 -0500
Received: by pxi4 with SMTP id 4so2387340pxi.33
        for <netdev@vger.kernel.org>; Fri, 08 Jan 2010 14:50:42 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100108194222.GA8386@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 08, 2010 at 11:42:22AM -0800, Matt Carlson wrote:
> 
> Ah.  I may have found the problem.  Can you apply the below patch on top
> of the patch you already applied and see if this fixes the problem?
> 

Looks very promising...2+ hours and I haven't seen a single lockup.

-- 
Dmitry
