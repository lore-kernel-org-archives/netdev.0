From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Sat, 12 Feb 2005 01:07:32 +0100
Message-ID: <20050212000732.GC8792@electric-eye.fr.zoreil.com>
References: <41D2844E.5070204@phekda.gotadsl.co.uk> <20041229235203.GA5465@electric-eye.fr.zoreil.com> <41F250D1.8000207@phekda.gotadsl.co.uk> <41F26FD1.2060407@phekda.gotadsl.co.uk> <20050122230156.GC24461@electric-eye.fr.zoreil.com> <41F3F632.3060800@phekda.gotadsl.co.uk> <20050125214725.GA6093@electric-eye.fr.zoreil.com> <4204C981.6050102@phekda.gotadsl.co.uk> <20050205204135.GA13986@electric-eye.fr.zoreil.com> <420944AB.5090501@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <420944AB.5090501@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe <rich@phekda.gotadsl.co.uk> :
[...]
> I find that the "ip link set dev eth0 down" command hangs, consuming 
> most of the CPU time (~99%). Note that I issued the "network" commands 
> with about a second's delay between each command.

@#$*%!

Patch against 2.6.11-rc3:
http://www.fr.zoreil.com/people/francois/misc/20050211-2.6.11-rc3-r8169-test.patch

Better ?

Up-to-date patch-script version is available at:
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.11-rc3/r8169

--
Ueimor
