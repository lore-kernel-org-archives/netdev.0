From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] SMP support on 3c527 net driver for 2.6
Date: Tue, 21 Oct 2003 00:31:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F94B698.90508@pobox.com>
References: <Pine.LNX.4.21.0310201141280.404-300000@ps2.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, felipewd@terra.com.br, netdev@oss.sgi.com,
        linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Procter <rnp@paradise.net.nz>
In-Reply-To: <Pine.LNX.4.21.0310201141280.404-300000@ps2.local>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Procter wrote:
> On Sat, 18 Oct 2003, Andrew Morton wrote:
> 
> 
>>I've regenerated this against the current driver.  I'll include it in
>>test8-mm1.
>>
>>If the scsi problem is fixed could you please retest this driver on both
>>SMP and UP builds?
> 
>  
> Thanks --- will do. Note that it's only tested on UP. I'm trying to find
> someone with the requisite hardware. 
> (SMP + MCA + 3c527 + Linux = a rare beast).   


You can boot an SMP kernel on a uniprocessor machine.  In fact, doing so 
it a great test for deadlocks...

	Jeff
