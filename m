From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Fri, 20 Nov 2015 09:51:06 -0700
Message-ID: <564F4F7A.9000508@cumulusnetworks.com>
References: <CAKD1Yr2OgJT0GsrTuws0oapobrU+ML3NpBNBXizg6q035PH4MA@mail.gmail.com>
 <20151119.005318.838757439536205791.davem@davemloft.net>
 <CAKD1Yr0Es9JqdDi_05Kif=TyCSA+n7yDHUNr-ND-SD4j4p=D9A@mail.gmail.com>
 <20151119.195504.2050784646947745419.davem@davemloft.net>
 <CAKD1Yr356LxAATZQ4O8CO5wuek2nFbPGrtRMGzMyda819FZdRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej_=c5=bbenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Lorenzo Colitti <lorenzo@google.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38343 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760457AbbKTQvI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 11:51:08 -0500
Received: by igbxm8 with SMTP id xm8so16111169igb.1
        for <netdev@vger.kernel.org>; Fri, 20 Nov 2015 08:51:08 -0800 (PST)
In-Reply-To: <CAKD1Yr356LxAATZQ4O8CO5wuek2nFbPGrtRMGzMyda819FZdRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/19/15 6:55 PM, Lorenzo Colitti wrote:
> upstream alternatives. We might even be able to show up at netdev 1.1
> for some higher-bandwidth conversations.

This use case would make a great talk for netdev.

There are similar problems when netdev's are moved between namespaces 
(and VRFs).
