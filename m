From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] color: use "light" colors for dark background
Date: Fri, 24 Feb 2017 08:50:20 -0800
Message-ID: <20170224085020.482109b0@xeon-e3>
References: <20170224101312.31538-1-pvorel@suse.cz>
        <20170224.102817.1987967741498252394.davem@davemloft.net>
        <1487952702.30601.0.camel@sipsolutions.net>
        <20170224.112213.886902897151369899.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, pvorel@suse.cz, netdev@vger.kernel.org,
        m.nyman@iki.fi, yegorslists@googlemail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33473 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751253AbdBXQu3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 11:50:29 -0500
Received: by mail-pf0-f181.google.com with SMTP id o64so187829pfb.0
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 08:50:28 -0800 (PST)
In-Reply-To: <20170224.112213.886902897151369899.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Feb 2017 11:22:13 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Johannes Berg <johannes@sipsolutions.net>
> Date: Fri, 24 Feb 2017 17:11:42 +0100
> 
> >   
> >> > Chosen colors are questionable. Best solution would be also allow  
> >> user to  
> >> > redefine colors, like ls does with LS_COLORS or grep with  
> >> GREP_COLORS. But that  
> >> > is maybe overkill.  
> >> 
> >> I think you may have posted this to the wrong mailing list.  
> > 
> > Actually, it seems to just be missing the "iproute" (or so) prefix?  
> 
> Ok that makes more sense :)

Yes. Iproute2 has  had color support for a while.
The CC list has the original developer
