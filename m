From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [GENL]: Provide more information to userspace about registered
	genl families
Date: Fri, 01 Sep 2006 14:25:17 +0200
Message-ID: <1157113517.2878.55.camel@ux156>
References: <20060831212129.GF3470@postel.suug.ch>
	 <1157060812.5297.51.camel@jzny2>  <1157093281.2878.19.camel@ux156>
	 <1157113331.5057.67.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:2539 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751151AbWIAMYq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 08:24:46 -0400
To: hadi@cyberus.ca
In-Reply-To: <1157113331.5057.67.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-09-01 at 08:22 -0400, jamal wrote:

> Seems you may be talking about capabilities more than filtering?

yes, I had sort of thought filtering would be that, but now that you say
it I get the point :)

> Sorry, I havent had time to look at that code (is it in Daves tree?); 

No, it's not in any tree yet.

> if
> i understand you correctly - you have a superset of commands, and some
> users of those commands can only implement a subset?

precisely.

johannes
