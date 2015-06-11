From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: ssh connections hanging on 4.1rc7
Date: Thu, 11 Jun 2015 13:54:38 -0400
Message-ID: <20150611175438.GA3981@codemonkey.org.uk>
References: <20150611174618.GA30268@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:60421 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754546AbbFKRys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 13:54:48 -0400
Received: from [209.6.119.210] (helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1Z36ga-0005aN-KN
	for netdev@vger.kernel.org; Thu, 11 Jun 2015 18:54:40 +0100
Content-Disposition: inline
In-Reply-To: <20150611174618.GA30268@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 11, 2015 at 01:46:18PM -0400, Dave Jones wrote:
 > Just hit this weird problem where I can ssh into a machine once,
 > then after logging out, subsequent ssh connections hang.
 > 
 > The client side looks like..
 
derp, missed half the tcpdump capture on both sides, and now
I can't reproduce it.  I'll resend if it happens again.

	Dave
