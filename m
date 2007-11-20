From: Ben Dooks <ben@fluff.org.uk>
Subject: Re: [patch 00/22] DM9000 updates for 2.6.25
Date: Tue, 20 Nov 2007 17:33:33 +0000
Message-ID: <20071120173333.GF3244@fluff.org.uk>
References: <20071119203910.687238131@fluff.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:51093 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751032AbXKTRdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 12:33:39 -0500
Received: from ben by kira.home.fluff.org with local (Exim 4.68)
	(envelope-from <ben@fluff.org.uk>)
	id 1IuWyb-0001zq-NS
	for netdev@vger.kernel.org; Tue, 20 Nov 2007 17:33:33 +0000
Content-Disposition: inline
In-Reply-To: <20071119203910.687238131@fluff.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2007 at 08:39:10PM +0000, Ben Dooks wrote:
> This is my current proposed patch series to the DM9000
> driver for both general cleanups, support for ethtool
> and to make the code better.

Apologies, it seems that when I updated it to 2.6.24-rc3
it turns out I applied it without first upgrading the
underlying kernel source to that version. I will post
a new series to the list once i've fixed up all the
changes.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
