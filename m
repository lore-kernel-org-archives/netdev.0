From: Ben Greear <greearb@candelatech.com>
Subject: Re: Why was the /proc info removed from e1000 ?
Date: Thu, 30 Jan 2003 08:51:06 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E3957FA.6050500@candelatech.com>
References: <3E388D19.4000004@candelatech.com> <slrnb3ikqi.i0h.lunz@stoli.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <slrnb3ikqi.i0h.lunz@stoli.localnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jason Lunz wrote:
> greearb@candelatech.com said:
> 
>>I just noticed in the latest changelog that the /proc support was
>>removed from the e1000 driver?  I always found this usefull...any
>>reason why it was deleted?
> 
> 
> shortly lower in the changelog, you'll see that the same stats are now
> availble using the standard ethtool interface. I don't know whether you
> need a new ethtool to make sense of the e1000 stats struct.
> 
> Jason

It was nice to not have to have to dredge up the latest ethtool binary
in order to see the pretty stats.  However, I am glad to see more stuff
supported by the ethtool interface.

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
