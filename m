From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] via-rhine: do not abort due to invalid MAC address
Date: Wed, 09 Mar 2011 13:30:09 -0800 (PST)
Message-ID: <20110309.133009.260076598.davem@davemloft.net>
References: <4D700D66.5090300@gmail.com>
	<20110303.140134.241924015.davem@davemloft.net>
	<4D701178.8000102@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rl@hellgate.ch, florian@openwrt.org, netdev@vger.kernel.org
To: mr.nuke.me@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57607
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753077Ab1CIV3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 16:29:31 -0500
In-Reply-To: <4D701178.8000102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alex G." <mr.nuke.me@gmail.com>
Date: Fri, 04 Mar 2011 00:08:56 +0200

> On 03/04/2011 12:01 AM, David Miller wrote:
>> 
>> Still wrong, the patch needs to be "-p1" not "-p0" rooted.
> 
> Documentation/SubmittingPatches seems to be outdated then. I used "git
> diff"; I hope the format is correct this time

Please submit patches as fresh new list postings, rather than in reply
to another email, otherwise I have to do a lot of editing to get the
commit message to look right.

Also:

Signed-off-by Alexandru Gagniuc <mr.nuke.me@gmail.com>

You're missing a colon character at the end of "Signed-off-by"
