From: Ben Greear <greearb@candelatech.com>
Subject: Re: Favorite network stress tests?
Date: Wed, 30 Apr 2003 16:47:58 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EB060AE.9050708@candelatech.com>
References: <20030430163542.4e09076f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030430163542.4e09076f.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Does any one have a favorite network stress test?
> There are the usual benchmarks like ttcp, netbench, are there others?
> NFS? 
> 

pktgen is good for testing/abusing drivers, below the IP stacks.

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
