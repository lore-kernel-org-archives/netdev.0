From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
Date: Fri, 14 Sep 2007 11:59:25 -0400
Message-ID: <46EAAFDD.6010905@garzik.org>
References: <20070911164033.GA3754@gospo.rdu.redhat.com> <20070914153629.GA9140@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, baum@tehutinetworks.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59487 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750822AbXINP7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 11:59:33 -0400
In-Reply-To: <20070914153629.GA9140@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:
> On Tue, Sep 11, 2007 at 12:40:34PM -0400, Andy Gospodarek wrote:
>> This introduces support for a line of 10GbE adapters made by Tehuti
>> Networks.  An attempt to get this included was made a few months ago and
>> since the driver has been re-factored based on Jeff's suggestions.
>>
>> You can download a patch against Jeff's netdev-2.6#upstream tree here:
>>
>> http://git.greyhouse.net/gospo/tehuti-netdev-26-upstream.patch
>>
>> and I setup a git tree last night based off Linus' tree.  You can sync
>> with that here if you like:
>>
>> http://git.greyhouse.net/gospo/tehuti-2.6.git
>>
> 
> I moved this to:
> 
> git://git.greyhouse.net/gospo/tehuti-2.6.git
> 
> since I got some complaints that the http-based git tree wasn't working
> well.

Maybe you forgot git-update-server-info, after pushing ?

	Jeff



