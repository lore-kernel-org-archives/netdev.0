From: jamal <hadi@cyberus.ca>
Subject: Re: Fw: [Bugme-new] [Bug 4177] New: Please consider adding
	possibility to have multiple PPPoE sessions with different MAC addresses
Date: 06 Feb 2005 16:45:08 -0500
Message-ID: <1107726307.1054.38.camel@jzny.localdomain>
References: <20050206122604.74a41796.akpm@osdl.org>
	 <1107723057.1055.28.camel@jzny.localdomain>
	 <20050206212500.GF17682@torres.l21.ma.zugschlus.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
To: Marc Haber <mh+kernel-bugzilla@zugschlus.de>
In-Reply-To: <20050206212500.GF17682@torres.l21.ma.zugschlus.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-02-06 at 16:25, Marc Haber wrote:
> On Sun, Feb 06, 2005 at 03:50:57PM -0500, jamal wrote:
> > Does that patch help at all?
> 
> It helps with the user space pppoed, yes.

Remind me again: With user space pppoe if you have a web server that
people access from outside world, all packets go to user space and then
back to the kernel before hitting user space again? Only in such a case
can i see this working ...

cheers,
jamal
