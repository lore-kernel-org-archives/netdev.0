From: AndyLiebman@aol.com
Subject: Re: Frequent Oops on Shutdown 2.6.10
Date: Tue, 22 Feb 2005 18:30:13 EST
Message-ID: <68.4ffa26be.2f4d1a85@aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: terryg@axian.com, netdev@oss.sgi.com, davem@davemloft.net, akpm@osdl.org
To: AndyLiebman@aol.com, herbert@gondor.apana.org.au, yoshfuji@linux-ipv6.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I tested my server today several  times. I booted up and shutdown the server 
eight times while running the 2.6.10  kernel. Six times the sever shut down 
fine. Two times -- only when I had  unplugged the Ethernet connection during my 
session -- I got the Oops when I  shut down Ini both cases, it was about 2 
minutes after unplugging the Ethernet  cable.  

So, do you know what this means? Sure, the easy solution  would be "don't 
unplug the Ethernet cable while you're running." I can follow  that rule, but out 
in the field where the servers go, there will be accidents.  

Should I still try that patch? 

Regards, 
Andy Liebman  
