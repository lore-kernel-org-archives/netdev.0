From: Horst von Brand <vonbrand@inf.utfsm.cl>
Subject: Re: eepro100/e100 broken in 2.6.13-rc3
Date: Thu, 14 Jul 2005 16:07:18 -0400
Message-ID: <200507142007.j6EK7Iax030363@laptop11.inf.utfsm.cl>
References: <jesse.brandeburg@gmail.com>
Cc: Mikhail Kshevetskiy <kl@laska.dorms.spbu.ru>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263138AbVGNULy@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: Message from Jesse Brandeburg <jesse.brandeburg@gmail.com>
   of "Wed, 13 Jul 2005 23:28:15 MST." <4807377b05071323286963bf3a@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg <jesse.brandeburg@gmail.com> wrote:
> On 7/13/05, Mikhail Kshevetskiy <kl@laska.dorms.spbu.ru> wrote:
> > symptom
> > =======
> > modprobe e100
> > ifconfig eth0 <ip> netmask <netmask>
> > 
> > result:
> > =======
> > SIOCADDRT: Network is unreachable
> > 
> > There were no such error in 2.6.13-rc2

> odd, both e100 and eepro100 are broken?  This might indicate something
> wierd with the pci layer.  Don't know what might cause the Network is
> unreachable...

It works fine here... latest .git from yesterday.
-- 
Dr. Horst H. von Brand                   User #22616 counter.li.org
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513
