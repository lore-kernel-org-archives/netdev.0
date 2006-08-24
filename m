From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/4] Try 2: Add wireless statistics to d80211
Date: Thu, 24 Aug 2006 17:03:33 +0200
Message-ID: <20060824170333.2d26cad7@griffin.suse.cz>
References: <44ED16AB.2080306@lwfinger.net>
	<20060824135934.4df0b1ba@griffin.suse.cz>
	<44EDBA38.4020109@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:61412 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751583AbWHXPDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 11:03:35 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44EDBA38.4020109@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 24 Aug 2006 09:39:52 -0500, Larry Finger wrote:
> Noted on the first part, but I would like a clarification regarding style. I put the */ on the 
> second line to match the rest of that section. Should a patch try to keep the local style in that 
> part of the code, or change it to a some other standard?

Patches should convert the code they are touching to coding style common
in the kernel. This way we will gradually convert at least part of
d80211 to the kernel coding style; the rest will be addressed by one big
patch just before merging into the vanilla (or -mm).

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
