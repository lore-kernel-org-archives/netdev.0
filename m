From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: add device groups
Date: Mon, 10 Jan 2011 15:38:30 +0100
Message-ID: <1294670310.3583.16.camel@jlt3.sipsolutions.net>
References: <1294659524-22509-1-git-send-email-ddvlad@rosedu.org>
	 <1294666875.3583.6.camel@jlt3.sipsolutions.net>
	 <1294668021.6063.315.camel@mojatatu>
	 <1294668505.3583.9.camel@jlt3.sipsolutions.net>
	 <1294669450.6063.319.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:49048 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166Ab1AJOie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 09:38:34 -0500
In-Reply-To: <1294669450.6063.319.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-01-10 at 09:24 -0500, jamal wrote:

> > It also means the
> > grouping is entirely user-space controlled. In this case, the idea of
> > automatically grouping based on the device structure seems pointless.
> 
> You still havent said what you want this grouping for. What is your
> use case? ;->

I don't have a use case. I was just wondering if there's any benefit in
grouping virtual devices that belong to a single physical device, but I
suppose there isn't.

johannes

