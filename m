From: "Johannes Berg" <johannes@sipsolutions.net>
Subject: Re: [GENL]: Provide more information to userspace about registered
     genl families
Date: Sun, 3 Sep 2006 14:04:36 +0200 (CEST)
Message-ID: <63206.84.147.135.91.1157285076.squirrel@secure.sipsolutions.net>
References: <20060831212129.GF3470@postel.suug.ch>
    <1157060812.5297.51.camel@jzny2> <1157093281.2878.19.camel@ux156>
    <1157113331.5057.67.camel@jzny2> <1157113517.2878.55.camel@ux156>
    <1157115624.5057.89.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Thomas Graf" <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:2447 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751305AbWICMEs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Sep 2006 08:04:48 -0400
In-Reply-To: <1157115624.5057.89.camel@jzny2>
To: hadi@cyberus.ca
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:

> Could you point me to it? I can look at it over the weekend.

I posted it here on netdev, look for nl80211.

> It may be we need to add another feature to genl to accomodate this.
> Example by setting a flag to indicate supportability. However, it does
> sound like this is something your code needs to own in a capability set
> structure somewhere. I cant tell without looking at the code.

Yes, I'm currently exporting it myself.

johannes

-- 
VGER BF report: U 0.534475
