From: Ben Greear <greearb@candelatech.com>
Subject: Re: 8169 driver with NetGear GA511 card.
Date: Thu, 28 Oct 2004 09:52:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <418123E4.2010105@candelatech.com>
References: <41802CA8.8070900@candelatech.com> <200410281145.10600.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200410281145.10600.jdmason@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason wrote:
> On Wednesday 27 October 2004 06:18 pm, Ben Greear wrote:
> 
>>A bit later, my keyboard just stopped working.  The scratch pad
>>and USB mouse continued to work.  System wouldn't shut down all
>>the way either...forced fsck, system is back online.
> 
> 
> I was seeing similar behavior with high workloads and TSO.  Can you confirm 
> that you are running with TSO on?  

I'll have to check, but I do know that the traffic I was sending was
at the ethernet frame level and it was UDP packets.

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
