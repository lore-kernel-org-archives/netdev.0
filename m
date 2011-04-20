From: Dave Jones <davej@redhat.com>
Subject: Re: can: add missing socket check in can/raw release.
Date: Wed, 20 Apr 2011 15:04:44 -0400
Message-ID: <20110420190443.GA13725@redhat.com>
References: <4DAEC7A0.1090103@hartkopp.net>
 <20110420.120218.15220634.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: socketcan@hartkopp.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42959 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755605Ab1DTTEu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 15:04:50 -0400
Content-Disposition: inline
In-Reply-To: <20110420.120218.15220634.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 20, 2011 at 12:02:18PM -0700, David Miller wrote:
 > From: Oliver Hartkopp <socketcan@hartkopp.net>
 > Date: Wed, 20 Apr 2011 13:46:40 +0200
 > 
 > > We can get here with a NULL socket argument passed from userspace,
 > > so we need to handle it accordingly.
 > > 
 > > Thanks to Dave Jones pointing at this issue in net/can/bcm.c
 > > 
 > > Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
 > 
 > I already applied Dave's patch from last night.

This is in a different path.

	Dave
