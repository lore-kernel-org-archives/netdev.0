From: "arun4linux" <arun4linux@indiatimes.com>
Subject: Re: Re: pci-skeleton duplex check
Date: Sat, 14 Dec 2002 20:05:17 +0530
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200212141428.TAA32276@WS0005.indiatimes.com>
Reply-To: "arun4linux"<arun4linux@indiatimes.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "Michael Richardson"<mcr@sandelman.ottawa.on.ca>, <netdev@oss.sgi.com>,
   "Linux Kernel Mailing List"<linux-kernel@vger.kernel.org>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

&lt;&lt;Interfaces should NEVER change in patch level versions.
Just *DO NOT DO IT*.
&gt;&gt;I do agree on this.


This is a common complaint about linux kernel developers. And this always gives an insecure feeling  :-) for the device driver or kernel module programmers. 
This was one of the issues in my earlier company/work and they have gone for another OS.


Warm Regards


Arun
"Michael Richardson" wrote:



-----BEGIN PGP SIGNED MESSAGE-----


&gt;&gt;&gt;&gt;&gt; "Donald" == Donald Becker writes:
Donald&gt; The drivers in the kernel are now heavily modified and have significantly
Donald&gt; diverged from my version. Sure, you are fine with having someone else
Donald&gt; do the difficult and unrewarding debugging and maintainence work, while
Donald&gt; you work on just the latest cool hardware, change the interfaces and are
Donald&gt; concerned only with the current kernel version.

I agree strongly with Donald.

Interfaces should NEVER change in patch level versions.
Just *DO NOT DO IT*.

Go wild in odd-numbered.. get the interfaces right there.
But leave them alone afterward.

This is a fundamental tenant of being professional. Otherwise, the kernel
people are the biggest reason I've ever seen for using *BSD.
Microsoft is not the real enemy. Gratuitous change is.

] ON HUMILITY: to err is human. To moo, bovine. | firewalls [
] Michael Richardson, Sandelman Software Works, Ottawa, ON |net architect[
] mcr@sandelman.ottawa.on.ca http://www.sandelman.ottawa.on.ca/ |device driver[
] panic("Just another Debian GNU/Linux using, kernel hacking, security guy"); [


Get Your Private, Free E-mail from Indiatimes at  http://email.indiatimes.com
Buy the best in Movies at http://www.videos.indiatimes.com
Change the way you talk. Indiatimes presents "Valufon", Your PC to Phone service with clear voice at rates far less than the normal ISD rates. Go to http://www.valufon.indiatimes.com. Choose your plan. BUY NOW.


[[HTML alternate version deleted]]
