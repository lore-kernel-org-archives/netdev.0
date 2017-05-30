From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: 'iw events' stops receiving events after a while on 4.9 + hacks
Date: Tue, 30 May 2017 15:18:42 +0200
Message-ID: <1496150322.3327.9.camel@sipsolutions.net>
References: <d82d191e-8ede-68c6-c9e0-c381dc874d36@candelatech.com>
         <20170517100844.GC2849@medion.lan>
         <1495027835.2442.13.camel@sipsolutions.net>
         <fa96dfad-8d1b-c48f-df3b-3df0d548a5c6@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>, Bastian Bittorf <bb@npl.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:57436 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751037AbdE3NSp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 30 May 2017 09:18:45 -0400
In-Reply-To: <fa96dfad-8d1b-c48f-df3b-3df0d548a5c6@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-17 at 08:22 -0700, Ben Greear wrote:
> 
> I saw it exactly once so far, and it happened overnight,
> but we have not been doing a lot of work with the 4.9 kernel until
> recently.
> 
> I don't think there were many messages on this system, and certainly
> others have run much longer on systems that should be generating many
> more events without trouble.

Ok.

> Is there any way to dump out the socket information if we reproduce
> the problem?

I have no idea, sorry.

If you or Bastian can tell me how to reproduce the problem, I can try
to investigate it.

johannes
