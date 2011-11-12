From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next V7] net: introduce ethernet teaming device
Date: Sat, 12 Nov 2011 09:18:48 +0100
Message-ID: <20111112081847.GA2130@minipsycho.orion>
References: <20111111170509.581c4ca2@asterix.rh>
 <20111111175845.10c82c3c@asterix.rh>
 <20111112001459.GA2448@minipsycho.orion>
 <20111112.004555.1043819970109229358.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fbl@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, benjamin.poirier@gmail.com, jzupka@redhat.com,
	ivecera@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27446 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751928Ab1KLITA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Nov 2011 03:19:00 -0500
Content-Disposition: inline
In-Reply-To: <20111112.004555.1043819970109229358.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Nov 12, 2011 at 06:45:55AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Sat, 12 Nov 2011 01:15:00 +0100
>
>> Yes, this should be checked. I missed that. I would like to address this
>> as follow up patch because I'm sure it's not the last bug in team (I
>> would be sending Vx of the patch for long time :( )
>
>No, Jiri.  Known bugs with obvious fixes get fixed first.
>
>You see it as an endless process, but rather the code just isn't ready
>yet if people can still find easy to diagnose and fix flaws so
>quickly.

Okay, v8 posted.

thanks Dave.
