From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] checkpatch: Add --strict preference for #defines using
 BIT(foo)
Date: Sun, 09 Nov 2014 06:22:09 -0800
Message-ID: <1415542929.23530.39.camel@perches.com>
References: <1415265610-9338-1-git-send-email-jiri@resnulli.us>
	 <1415265610-9338-10-git-send-email-jiri@resnulli.us>
	 <20141107.151607.480474516800359791.davem@davemloft.net>
	 <1415394939.23530.20.camel@perches.com>
	 <20141109095025.GA1840@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0104.hostedemail.com ([216.40.44.104]:37016 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751728AbaKIOWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 09:22:13 -0500
In-Reply-To: <20141109095025.GA1840@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-09 at 10:50 +0100, Jiri Pirko wrote:
> Joe, regarding the other Dave's comment, the multiline one, that is also
> not covered by checkpatch. Would please you take care of that as well?

No, as far as I know, it's not feasible given
insertion/deletion, but you are welcome to try.
