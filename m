From: Ben Dooks <ben@fluff.org>
Subject: Re: [PATCH 07/24 for-2.6.25] DM9000: Add initial ethtool support
Date: Wed, 6 Feb 2008 22:16:00 +0000
Message-ID: <20080206221600.GF15407@fluff.org.uk>
References: <20080205000159.432081941@fluff.org.uk> <20080205000815.759244139@fluff.org.uk> <20080205225045.GA12258@electric-eye.fr.zoreil.com> <20080206220334.GE15407@fluff.org.uk> <20080206215254.GA3212@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben@fluff.org>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:55400 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756498AbYBFWQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 17:16:07 -0500
Content-Disposition: inline
In-Reply-To: <20080206215254.GA3212@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 06, 2008 at 10:52:54PM +0100, Francois Romieu wrote:
> Ben Dooks <ben@fluff.org> :
> [...]
> > The next patch in the series changes the locking.
> 
> Do you mean patch #08 ?

Sorry, looked at the wrong patch, it is #11 which changes the locking
for address register accesses.
-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
