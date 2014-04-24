From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next 0/2] tipc: add support for link state
 subscriptions
Date: Thu, 24 Apr 2014 12:52:50 +0200
Message-ID: <20140424105250.GO7234@eerihug-hybrid.rnd.ki.sw.ericsson.se>
References: <1398265275-19849-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ying.xue@windriver.com>, <paul.gortmaker@windriver.com>,
	<richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
	<jon.maloy@ericsson.com>, <maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:63674 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754022AbaDXKww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 06:52:52 -0400
Content-Disposition: inline
In-Reply-To: <1398265275-19849-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 23, 2014 at 05:01:13PM +0200, erik.hugne@ericsson.com wrote:
> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> Low level topology information like TIPC link up/down is useful for
> applications like teamd to make smarter failover decisions in a
> HA cluster environment. Fetching logical link names through an ioctl
> may hurt the eyes of some. Suggestions for a more elegant way of doing
> this would be appreciated in that case. :)
>

Please ignore this set, i just noticed it doesn't apply cleanly 
(pebkac on my side). Will do a v2 resend, sorry.

//E
