From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [net-next 0/3] tipc: improve interaction socket-link
Date: Mon, 16 Jan 2017 20:35:08 +0000
Message-ID: <A2BAEFC30C8FD34388F02C9B3121859D225F44DE@eusaamb103.ericsson.se>
References: <1483457208-29033-1-git-send-email-jon.maloy@ericsson.com>
 <20170116.144514.1071967219363714348.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>,
        Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>,
        Ying Xue <ying.xue@windriver.com>,
        "maloy@donjonn.com" <maloy@donjonn.com>,
        "tipc-discussion@lists.sourceforge.net"
        <tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usplmg21.ericsson.net ([198.24.6.65]:64480 "EHLO
        usplmg21.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750858AbdAPUf1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 15:35:27 -0500
In-Reply-To: <20170116.144514.1071967219363714348.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of David Miller
> Sent: Monday, 16 January, 2017 14:45
> To: Jon Maloy <jon.maloy@ericsson.com>
> Cc: netdev@vger.kernel.org; viro@zeniv.linux.org.uk; Parthasarathy Bhuvaragan
> <parthasarathy.bhuvaragan@ericsson.com>; Ying Xue
> <ying.xue@windriver.com>; maloy@donjonn.com; tipc-
> discussion@lists.sourceforge.net
> Subject: Re: [net-next 0/3] tipc: improve interaction socket-link
> 
> From: Jon Maloy <jon.maloy@ericsson.com>
> Date: Tue,  3 Jan 2017 10:26:45 -0500
> 
> > We fix a very real starvation problem that may occur when a link
> > encounters send buffer congestion. At the same time we make the
> > interaction between the socket and link layer simpler and more
> > consistent.
> 
> This doesn't apply to net-next, also the Date in your emails is 10 days
> in the past.  What's going on here?

I don't know. This series was sent in on Jan 3rd, and applied by you the same day. Maybe the mail server decided to send you a duplicate?

///jon
