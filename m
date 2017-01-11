From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/4] net: switchdev: Avoid sleep in atomic with
 DSA
Date: Wed, 11 Jan 2017 15:59:34 +0100
Message-ID: <20170111145934.GU22820@lunn.ch>
References: <20170109194503.10713-1-f.fainelli@gmail.com>
 <20170109204849.GA28310@splinter>
 <e28f29c8-04ed-1d71-7b13-27a5d58d111c@gmail.com>
 <20170109211436.GB28310@splinter>
 <20170110120846.GC1827@nanopsycho>
 <20170110132506.GA4084@splinter.mtl.com>
 <20170110141807.GD1827@nanopsycho>
 <20170110160852.GA18050@splinter.mtl.com>
 <03ce7d38-7775-3cd7-d863-682316d949bf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ido Schimmel <idosch@idosch.org>, Jiri Pirko <jiri@resnulli.us>,
        netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55107 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938050AbdAKO7h (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 09:59:37 -0500
Content-Disposition: inline
In-Reply-To: <03ce7d38-7775-3cd7-d863-682316d949bf@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Vivien, Andrew, are you aware of an use case where we have the HW
> programmed with a superset of VLANs wrt. the SW bridge?

I cannot think of any case with a superset. Subset yes, but not
superset.

	Andrew
