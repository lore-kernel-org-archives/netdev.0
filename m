From: "C. McPherson" <ccmcphe@verizon.net>
Subject: Re: [PATCH 2/2] cfg80211: deprecate CFG80211_WEXT
Date: Fri, 18 May 2012 13:39:34 -0400
Message-ID: <4FB68956.8050909@verizon.net>
References: <20120516214017.936343357@sipsolutions.net>
 <20120516214048.739945597@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Christopher Worsley <christoph3r@partviking.com>,
	Adam <will.work4less@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173009pub.verizon.net ([206.46.173.9]:50080 "EHLO
	vms173009pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965949Ab2ERRj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 13:39:56 -0400
Received: from [192.168.1.4] ([unknown] [173.66.165.243])
 by vms173009.mailsrvcs.net
 (Sun Java(tm) System Messaging Server 7u2-7.02 32bit (built Apr 16 2009))
 with ESMTPA id <0M4800JV5BPYBS80@vms173009.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 18 May 2012 12:39:35 -0500 (CDT)
In-reply-to: <20120516214048.739945597@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please reconsider this! We still have applications that still use some 
CFG80211_WEXT functions. Can't you just disable it as default?

-Clyde

On 05/16/2012 05:40 PM, Johannes Berg wrote:
