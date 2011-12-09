From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH iproute2] red: harddrop support and cleanups
Date: Thu, 8 Dec 2011 16:44:26 -0800
Message-ID: <20111208164426.03248ca8@nehalam.linuxnetplumber.net>
References: <1323385900.2529.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48549 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751094Ab1LIAo2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 19:44:28 -0500
In-Reply-To: <1323385900.2529.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 09 Dec 2011 00:11:40 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Add harddrop support (kernel support added a long time ago), and various
> cleanups.
> 
> min BYTES, max BYTES are now optional and follow Sally Floyd's
> recommendations.
> 
> By the way, our default 2% probability is a bit low, Sally recommends
> 10%.
> Not a big deal if upcoming adaptative algo is deployed.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied (minor whitespace cleanup).
