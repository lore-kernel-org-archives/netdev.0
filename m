From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v4] netpoll: fix some sparse warnings in
 various places
Date: Mon, 18 Feb 2013 10:55:26 +0800
Message-ID: <1361156126.5967.8.camel@cr0>
References: <1361003873-20622-1-git-send-email-amwang@redhat.com>
	 <20130216091808.GA1536@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755005Ab3BRCzn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2013 21:55:43 -0500
In-Reply-To: <20130216091808.GA1536@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-02-16 at 10:18 +0100, Jiri Pirko wrote:
> 
> Hmm. I'm just wondering if there wouldn't be nicer for these functions
> to
> return bool if you just want to know if npinfo is null or not. This
> notation seems a bit confusing to me. 

Yes, makes sense.
