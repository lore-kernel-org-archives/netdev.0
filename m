From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH]  802.1Q VLAN
Date: Mon, 25 Oct 2004 16:56:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417D929A.2090809@candelatech.com>
References: <41797696.9070905@candelatech.com>	<20041022214611.GA4948@electric-eye.fr.zoreil.com>	<41798506.1030909@candelatech.com> <417D675F.3000909@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
In-Reply-To: <417D675F.3000909@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> 
> Ok, I believe I have fixed all the suggestions offered by Francois 
> (thanks!).
> 
> Please see what you think of this updated patch.  The changes have
> been compile tested...and will pass some data in just a few minutes to
> make sure nothing funny happens...
> 
> Thanks,
> Ben

I've been beating on it with pktgen for a while, and it seems stable.

DaveM, please consider accepting this patch (it's in a previous email to netdev,
just ask if you want it re-sent.)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
