From: David Miller <davem@davemloft.net>
Subject: Re: Networking security fixes
Date: Mon, 24 Apr 2017 16:07:54 -0400 (EDT)
Message-ID: <20170424.160754.2119121657456029872.davem@davemloft.net>
References: <1493063249.10415.78.camel@codethink.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, netdev@vger.kernel.org
To: ben.hutchings@codethink.co.uk
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1493063249.10415.78.camel@codethink.co.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Date: Mon, 24 Apr 2017 20:47:29 +0100

> Please queue up these fixes for 4.10.y:
> 
> 8605330aac5a tcp: fix SCM_TIMESTAMPING_OPT_STATS for normal skbs
> 4ef1b2869447 tcp: mark skbs with SCM_TIMESTAMPING_OPT_STATS

Ok, queued up, thanks.

> Please can you also send the pending fixes to Greg soon, as the
> AF_PACKET issue is quite serious?

I will get to it as soon as I can.
