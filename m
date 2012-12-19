From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 1/4] net: add change_carrier netdev op
Date: Wed, 19 Dec 2012 10:32:44 +0100
Message-ID: <20121219093244.GD1637@minipsycho.orion>
References: <1355868858-1713-2-git-send-email-jiri@resnulli.us>
 <1355871771.30992.44.camel@dcbw.foobar.com>
 <20121219082050.GA1637@minipsycho.orion>
 <20121219.012825.1076148821070092794.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dcbw@redhat.com, netdev@vger.kernel.org, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, fbl@redhat.com, john.r.fastabend@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f43.google.com ([74.125.83.43]:42670 "EHLO
	mail-ee0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751278Ab2LSJct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 04:32:49 -0500
Received: by mail-ee0-f43.google.com with SMTP id e49so891552eek.2
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 01:32:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20121219.012825.1076148821070092794.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 19, 2012 at 10:28:25AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 19 Dec 2012 09:20:50 +0100
>
>> Okay - I'll repost this single patch with your text as comment.
>
>Please always repost an entire series, rather than just part of
>it.

Sorry, I thought that in this case where the change is in one patch and
only cosmethic it wouldn't be a problem. Reposting the whole patchset.
