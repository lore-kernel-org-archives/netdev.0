From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Wed, 25 Feb 2009 14:15:50 +0100
Message-ID: <20090225131550.GA24996@xi.wantstofly.org>
References: <49A49C06.90908@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:59633 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbZBYNPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 08:15:52 -0500
Content-Disposition: inline
In-Reply-To: <49A49C06.90908@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2009 at 06:16:54PM -0700, Gary Thomas wrote:

> Is there support for this device anywhere?  In particular,
> the M88E6095 switch.

Not at the moment, but it should be easy enough to add.  If your
board already runs on 2.6.28+, I can whip up some patches for you
to try from the docs I have for that part.
