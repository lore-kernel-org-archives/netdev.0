From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: buggy IFB driver change
Date: Tue, 30 Jan 2007 14:13:14 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0701301411170.3611@woody.linux-foundation.org>
References: <20070130.131246.71091370.davem@davemloft.net> <45BFBE1B.2040508@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	m.kozlowski@tuxland.pl, Andrew Morton <akpm@osdl.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:54090 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751905AbXA3WNW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 17:13:22 -0500
In-Reply-To: <45BFBE1B.2040508@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 30 Jan 2007, Jeff Garzik wrote:
> 
> I'm about to crash, can you or Linus handle the correction?

Reverted, pushed out.

Davem, if you have any other issues, just push me any fixes. I'm going to 
do a final -rc7 today (way too many changes for me to be happy releasing a 
2.6.20 without a new -rc after all), and hope for the final 2.6.20 by the 
end of this week.

Sounds like a plan?

		Linus
