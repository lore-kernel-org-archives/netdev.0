From: James Morris <jmorris@redhat.com>
Subject: Re: Change proxy_arp to respond only for valid neighbours
Date: Mon, 9 Feb 2004 16:26:46 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0402091626260.3557-100000@thoron.boston.redhat.com>
References: <20040209121926.6f016ebf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Julian Anastasov <ja@ssi.bg>, <netdev@oss.sgi.com>, <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040209121926.6f016ebf.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 9 Feb 2004, David S. Miller wrote:

> RTCF_*NAT is dead wood, the existing route nating stuff is totally broken
> an unusable in 2.6.x, the eventual plan was to code up XFRM engine version
> of that feature but this is of course not done.  Since nobody is complaining
> about lack of routing NAT in 2.6.x, I think we should just kill off all references
> and if someone gets inspired they can code up the XFRM engine version.

Sounds like a plan.


- James
-- 
James Morris
<jmorris@redhat.com>
