From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: ZyXEL GN650-T
Date: Wed, 10 Nov 2004 00:25:10 +0100
Message-ID: <20041109232510.GA5582@electric-eye.fr.zoreil.com>
References: <20041107214427.20301.qmail@focomunicatii.ro> <20041107224803.GA29248@electric-eye.fr.zoreil.com> <20041109000006.GA14911@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, alan@redhat.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: seby@focomunicatii.ro
Content-Disposition: inline
In-Reply-To: <20041109000006.GA14911@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> :
> seby@focomunicatii.ro <seby@focomunicatii.ro> :
> [...]
> > I just bouth a zyxel GN650T network card .. and it sems that vlan's don't 
> > work on this card .. anybody had this problems with this card .. 
> 
> Patch below against 2.6.10-rc1-bk15 + Jeff's netdev should convert the driver
> to the in-kernel vlan API.

Cr*p, the driver had not been backported to 2.4.x. Ok, instant patch (155 ko)
against 2.4.28-rc2 available at:
http://www.fr.zoreil.com/people/francois/misc/20041110-2.4.28-rc2-via-velocity-backport.patch

--
Ueimor
