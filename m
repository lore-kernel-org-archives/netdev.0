From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: fealnx oopses
Date: Fri, 26 Mar 2004 23:35:14 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040326233514.B26347@electric-eye.fr.zoreil.com>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403262157.21624.vda@port.imtp.ilyichevsk.odessa.ua> <40648CAF.5010203@pobox.com> <200403270014.23088.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Andreas Henriksson <andreas@fjortis.info>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200403270014.23088.vda@port.imtp.ilyichevsk.odessa.ua>; from vda@port.imtp.ilyichevsk.odessa.ua on Sat, Mar 27, 2004 at 12:14:42AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> :
[...]
> Yes. But on x86 a++ is atomic vs interrupts - it's a single instruction
> and interrupts happen on instruction boundaries only.

Do you realize that you are saying that the CPU can atomically increment an
integer which sits _in memory_ ?

Oops :o)

--
Ueimor
