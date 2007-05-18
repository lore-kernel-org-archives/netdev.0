From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/6] sky2: remove Gigabyte 88e8056 restriction
Date: Thu, 17 May 2007 20:44:09 -0400
Message-ID: <464CF6D9.10307@garzik.org>
References: <20070514193809.867470364@linux-foundation.org> <20070514193945.532045147@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43513 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754522AbXERAoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 20:44:14 -0400
In-Reply-To: <20070514193945.532045147@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> The problems with Gigabyte motherboards are system configuration dependent.
> Since it works fine for some users, it doesn't make sense to deprive
> them.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied 1-6, but I'm watching this change closely.  This area of code 
has seen quite a bit of change-it-then-change-it-back activity :/

	Jeff



