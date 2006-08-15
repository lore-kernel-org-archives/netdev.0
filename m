From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: sysfs vs. d80211 configuration
Date: Tue, 15 Aug 2006 12:02:19 +0200
Message-ID: <44E19BAB.1010507@sipsolutions.net>
References: <44E07662.8070506@sipsolutions.net> <Pine.NEB.4.64.0608142302560.21364@otaku.freeshell.org> <44E17A95.2040006@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexey Toptygin <alexeyt@freeshell.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:2502 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S965348AbWHOKCc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 06:02:32 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <44E17A95.2040006@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> Good point, that'll work. Then again, I want this to run on really 
> tiny architectures and I'm thinking some of them might not have 
> fork(), just vfork(). Hmm.
Then again, on those platforms there is no real benefit from dropping 
privs, is there. Heh.

johannes
