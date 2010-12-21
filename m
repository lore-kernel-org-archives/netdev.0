From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] iproute2: ip: add wilcard support for device matching
Date: Tue, 21 Dec 2010 08:14:22 -0500
Message-ID: <1292937262.6535.15.camel@mojatatu>
References: <1291993092-8675-1-git-send-email-opurdila@ixiacom.com>
	 <201012101932.59352.opurdila@ixiacom.com>
	 <1292002959.3580.321.camel@edumazet-laptop>
	 <201012102006.03401.opurdila@ixiacom.com>
	 <1292593088.2668.43.camel@mojatatu>  <4D0FAD26.8050908@rosedu.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: Vlad Dogaru <ddvlad@rosedu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:48260 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab0LUNOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 08:14:34 -0500
Received: by yxt3 with SMTP id 3so1752393yxt.19
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 05:14:33 -0800 (PST)
In-Reply-To: <4D0FAD26.8050908@rosedu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-20 at 11:23 -0800, Vlad Dogaru wrote:

> I'll try to implement this approach in the next few days.

Excellent ;-> Remember, this is general purpose tag, sort
like socket/route/skb->mark. It is upto the administrator to
define its use via policy. 

cheers,
jamal


