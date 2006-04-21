From: Piet Delaney <piet@bluelane.com>
Subject: Congestion Avoidance Monitoring Tools
Date: Thu, 20 Apr 2006 22:26:14 -0700
Message-ID: <1145597174.12413.17.camel@piet2.bluelane.com>
Reply-To: piet@bluelane.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Piet Delaney <piet@bluelane.com>, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@vger.kernel.org
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm upgrading our 2.6.12 kernel to 2.6.13, which includes significant
congestion avoidance code additions and changes. I was wondering if
there are any tools folks can recommend for testing the kernel to make
sure the congestion avoidance code is operating correctly. For 
example the displaying of the congestion window as a function of time
while undergoing convergence. For causing congestion I could modify 
a kernel to discard packets once in a while on a lab gateway and hit 
it with iperf. HP's netperf looks interesting. 

Any suggestions?


-piet

-- 
---
piet@bluelane.com

