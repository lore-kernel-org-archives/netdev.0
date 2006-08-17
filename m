From: Jiri Benc <jbenc@suse.cz>
Subject: Re: d80211 and sta_aid for AP functionality
Date: Thu, 17 Aug 2006 20:21:31 +0200
Message-ID: <20060817202131.3456ce00@griffin.suse.cz>
References: <44E02F41.2060300@sipsolutions.net>
	<44E0320C.6090003@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkm@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:13294 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S932563AbWHQSVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2006 14:21:33 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44E0320C.6090003@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Aug 2006 10:19:24 +0200, Johannes Berg wrote:
> Looking through the code, I notice that above (a) and (b) can be 
> collapsed into just keeping track of the TIM throughout the code. I 
> suppose that's meant by the comment above? Then we can't add the check 
> for saying 'hey you stupid userspace that AID is already used' but 
> that's ok I guess.
> 
> If you can confirm that my analysis is correct I'd be willing to try 
> making this change.

You understand it right (or at least the same way as me :-)) and this
effort would be highly appreciated.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
