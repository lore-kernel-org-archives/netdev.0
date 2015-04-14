From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/4] mac80211-hwsim: remove dmesg spam about get-survey.
Date: Tue, 14 Apr 2015 10:14:38 +0200
Message-ID: <1428999278.3019.8.camel@sipsolutions.net>
References: <1428095523-374-1-git-send-email-greearb@candelatech.com>
	 <1428095523-374-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:54375 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751179AbbDNIOq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 04:14:46 -0400
In-Reply-To: <1428095523-374-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-03 at 14:12 -0700, greearb@candelatech.com wrote:
> From: Ben Greear <greearb@candelatech.com>
> 
> This message just fills up dmesg and/or kernel logs and does
> not provide any useful information.

I'm fine with removing it but don't see much point in commenting it
out...

johannes
