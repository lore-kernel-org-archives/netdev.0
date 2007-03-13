From: Chris Stromsoe <cbs@cts.ucla.edu>
Subject: Re: [PATCH] skge: set mac address bonding fix
Date: Mon, 12 Mar 2007 17:37:40 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703121731020.27756@potato.cts.ucla.edu>
References: <Pine.LNX.4.64.0703081101390.21717@potato.cts.ucla.edu>
 <20070308113427.6344a7f6@freekitty> <Pine.LNX.4.64.0703081256440.25051@potato.cts.ucla.edu>
 <20070308134811.38a8ec81@freekitty> <Pine.LNX.4.64.0703081350510.25051@potato.cts.ucla.edu>
 <23552.1173395045@death> <Pine.LNX.4.64.0703081509110.28233@potato.cts.ucla.edu>
 <Pine.LNX.4.64.0703121504590.25767@potato.cts.ucla.edu>
 <20070312151626.60d00e30@dxpl.pdx.osdl.net> <Pine.LNX.4.64.0703121527320.25767@potato.cts.ucla.edu>
 <20070312161858.5fea9e63@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jgarzik@pobox.com>, Jay Vosburgh <fubar@us.ibm.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.smtp.ucla.edu ([169.232.46.137]:55876 "EHLO
	smtp-4.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752512AbXCMAhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 20:37:48 -0400
In-Reply-To: <20070312161858.5fea9e63@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Mar 2007, Stephen Hemminger wrote:

> Sounds like a dual-port only problem.. Unfortunately, I don't have 
> actual dual port skge hardware to test.  Try this:

That doesn't change the behavior at all.  I tested against 2.6.20.2 with 
skge from git and against 2.6.21-rc3-git7.

-Chris
