From: bert hubert <ahu@ds9a.nl>
Subject: Re: [RESEND] tuning linux for high network performance?
Date: Thu, 24 Oct 2002 14:42:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021024124222.GA32488@outpost.ds9a.nl>
References: <200210231218.18733.roy@karlsbakk.net> <200210231309.g9ND9Bp03373@Port.imtp.ilyichevsk.odessa.ua> <200210231536.24269.roy@karlsbakk.net> <200210241129.g9OBTpp09266@Port.imtp.ilyichevsk.odessa.ua> <20021024125030.A7529@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>,
   Roy Sigurd Karlsbakk <roy@karlsbakk.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20021024125030.A7529@flint.arm.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 24, 2002 at 12:50:31PM +0100, Russell King wrote:
> > gcc ... -o memory.o  ->  gcc ... -S -o memory.s ...
> 
> Have you tried make mm/memory.s ?

or even make mm/memory.lst

-- 
http://www.PowerDNS.com          Versatile DNS Software & Services
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
