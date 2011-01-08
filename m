From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH] iproute2: ip: add wilcard support for device matching
Date: Sat, 08 Jan 2011 13:10:58 -0800
Message-ID: <4D28D2E2.2060701@redfish-solutions.com>
References: <1291993092-8675-1-git-send-email-opurdila@ixiacom.com>	 <201012101932.59352.opurdila@ixiacom.com>	 <1292002959.3580.321.camel@edumazet-laptop>	 <201012102006.03401.opurdila@ixiacom.com>	 <1292593088.2668.43.camel@mojatatu>  <4D0FAD26.8050908@rosedu.org> <1292937262.6535.15.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Dogaru <ddvlad@rosedu.org>,
	Octavian Purdila <opurdila@ixiacom.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:41745 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751385Ab1AHVLV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Jan 2011 16:11:21 -0500
In-Reply-To: <1292937262.6535.15.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/21/10 5:14 AM, jamal wrote:
> On Mon, 2010-12-20 at 11:23 -0800, Vlad Dogaru wrote:
>
>> I'll try to implement this approach in the next few days.
> Excellent ;->  Remember, this is general purpose tag, sort
> like socket/route/skb->mark. It is upto the administrator to
> define its use via policy.
>
> cheers,
> jamal


Did that end up going anywhere?

There are a lot of cases where matching on "ppp*" would be handy.


