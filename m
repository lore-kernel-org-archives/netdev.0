From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RE: [Question] SMP for Linux
Date: Fri, 18 Oct 2002 18:16:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15792.13249.474279.391081@robur.slu.se>
References: <15790.42618.961289.506241@robur.slu.se>
	<008601c27602$a1ad8170$3701020a@CONCORDIA>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <J_Fraser@bit-net.com>
In-Reply-To: <008601c27602$a1ad8170$3701020a@CONCORDIA>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jon Fraser writes:
 > 
 > What was your cpu utilization like in the bound vs split scenarios?
 
 Not measured. Gonna take a look w. varient of Manfred's loadtest when  
 possible. But measuring the CPU this way also gives affects throughput. 
 Other softirq's are allowed to run as well now. :-)

 Over 1 Mpps was injected into eth0 so a good assumption is that for UP 
 all CPU is used but with SMP we might have some...
 
 > Does your e1000 driver have transmit interrupts enabled or disabled?
 
 transmit?  

 > I'd be really interested to see the results with two flows in opposite
 > directions.

 Me too.

 Cheers.
						--ro
