From: Dan Williams <dcbw@redhat.com>
Subject: Re: [patch 1/3] softmac: return -EAGAIN from getscan while scanning
Date: Sat, 15 Apr 2006 17:27:16 -0400
Message-ID: <1145136436.5963.6.camel@localhost.localdomain>
References: <20060411085805.949313000@sipsolutions.net>
	 <20060411085841.252064000@sipsolutions.net>
	 <20060413020010.2ab16d7b.zaitcev@redhat.com>
	 <1144919176.4187.44.camel@localhost> <1144920890.4187.50.camel@localhost>
	 <1144930441.2372.12.camel@localhost.localdomain>
	 <20060413161359.GA21074@bougret.hpl.hp.com>
	 <1145129056.6560.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, Pete Zaitcev <zaitcev@redhat.com>,
	netdev@vger.kernel.org, softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:26501 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751622AbWDOVbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2006 17:31:21 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1145129056.6560.0.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-04-15 at 21:24 +0200, Johannes Berg wrote:
> On Thu, 2006-04-13 at 09:13 -0700, Jean Tourrilhes wrote:
> 
> > 	Yes, Dan is 100% correct.
> 
> Right, slightly later I posted a patch to do it that way. After everyone
> else has discussed, do we agree to leave the patches as they are now?

Current patch set looks good to me.

Dan


