From: Ben Greear <greearb@candelatech.com>
Subject: Re: 2.6.10 ipv6/8021q lockup on vconfig on interface removal
Date: Mon, 17 Jan 2005 11:16:59 -0800
Message-ID: <41EC0F2B.7010002@candelatech.com>
References: <41EA0A01.2020707@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andre Tomt <andre@tomt.net>
In-Reply-To: <41EA0A01.2020707@tomt.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andre Tomt wrote:
> I sent this initially about a week ago, but nobody have said anything, 
> not even a confirmation that its beeing looked into, or about me beeing 
> silly - highly unusual on netdev! So I'm reposting (with slight 
> modifications), boo, shame on me. Just a bit worried it slipped through 
> the cracks.

My take on this is that it is a bug in the IPv6 code.  If the IPv6 people
think that the VLAN code might could be causing this, then I am open to
suggestions as to how the VLAN code might be in error....

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
