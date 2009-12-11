From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v2] Documentation: rw_lock lessons learned
Date: Fri, 11 Dec 2009 12:01:16 -0500
Message-ID: <4B227ADC.5010908@gmail.com>
References: <4AF9C540.5090403@gmail.com>	<20091110180646.2e5859a8@nehalam>	<4AFAEF78.4080807@gmail.com> <20091111093724.4f40a48d@nehalam> <4AFBEC44.9030409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Clark <sclark46@earthlink.net>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:19987 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755838AbZLKRBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2009 12:01:14 -0500
In-Reply-To: <4AFBEC44.9030409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:
> In recent weeks, two different network projects erroneously
> strayed down the rw_lock path.  Update the Documentation
> based upon comments by Eric Dumazet and Paul E. McKenney in
> those threads.
> 
> Merged with editorial changes by Stephen Hemminger.
> 
> Signed-off-by: William.Allen.Simpson@gmail.com
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> 
A month ago, I'd taken the final line "Ho humm.." of Linus'
response to mean he wasn't interested.  But at the local
discussion yesterday, I'm told that's just a typical Linusism.

The thread diverged into discussion of another document entirely.

I'm not the person to update this document with any of the other
information about global locks and tasklists and such.  But surely
somebody else could handle that in another patch.

Anybody have answers/updates to Linus's concerns about "pretty old
and bogus language"?  Would folks be interested in the update?
Does anybody know which list(s) would be better for discussion?
