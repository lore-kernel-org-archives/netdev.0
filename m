From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: pull-request: mac80211-next 2015-06-10
Date: Wed, 10 Jun 2015 16:07:08 +0200
Message-ID: <1433945228.3145.11.camel@sipsolutions.net>
References: <1433941752.3145.10.camel@sipsolutions.net>
	 (sfid-20150610_150922_643165_9D6C6EF2)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:58545 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965153AbbFJOHL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 10:07:11 -0400
In-Reply-To: <1433941752.3145.10.camel@sipsolutions.net> (sfid-20150610_150922_643165_9D6C6EF2)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-10 at 15:09 +0200, Johannes Berg wrote:

> The following changes since commit c3eee1fb1d308564ada5f7ea57bc51efc6130b37:
> 
>   Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge (2015-06-09 20:23:52 -0700)
> 
> are available in the git repository at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.git tags/mac80211-next-for-davem-2015-06-10
> 
> for you to fetch changes up to 5df03344c5639fdd848cb87553956df7276a8645:
> 
>   mac80211: convert HW flags to unsigned long bitmap (2015-06-10 13:48:42 +0200)

Oops, fixed a stupid bug in there so that's now commit
30686bf7f5b3c30831761e188a6e3cb33580fa48. Sorry about that.

johannes
