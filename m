From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: Favorite network stress tests?
Date: Wed, 30 Apr 2003 16:56:56 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EB062C8.3000203@us.ibm.com>
References: <20030430163542.4e09076f.shemminger@osdl.org> <3EB060AE.9050708@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3EB060AE.9050708@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
>> Does any one have a favorite network stress test?
>> There are the usual benchmarks like ttcp, netbench, are there others?
>> NFS?
> 
> 
> pktgen is good for testing/abusing drivers, below the IP stacks.

netperf is another for TCP/UDP stream and req/response
kind of stuff. There is support for sendfile, IPV6, etc.

thanks,
Nivedita
