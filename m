From: sebastian.ionita@focomunicatii.ro
Subject: Re: ZyXEL GN650-T
Date: Wed, 10 Nov 2004 22:10:10 +0200
Message-ID: <20041110201010.18341.qmail__19088.9650410556$1100160782$gmane$org@focomunicatii.ro>
References: <20041107214427.20301.qmail@focomunicatii.ro>
            <20041107224803.GA29248@electric-eye.fr.zoreil.com>
            <20041109000006.GA14911@electric-eye.fr.zoreil.com>
            <20041109232510.GA5582@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: seby@focomunicatii.ro, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        alan@redhat.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20041109232510.GA5582@electric-eye.fr.zoreil.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu writes: 

> Francois Romieu <romieu@fr.zoreil.com> :
>> seby@focomunicatii.ro <seby@focomunicatii.ro> :
>> [...]
>> > I just bouth a zyxel GN650T network card .. and it sems that vlan's don't 
>> > work on this card .. anybody had this problems with this card ..  
>> 
>> Patch below against 2.6.10-rc1-bk15 + Jeff's netdev should convert the driver
>> to the in-kernel vlan API.
> 
> Cr*p, the driver had not been backported to 2.4.x. Ok, instant patch (155 ko)
> against 2.4.28-rc2 available at:
> http://www.fr.zoreil.com/people/francois/misc/20041110-2.4.28-rc2-via-velocity-backport.patch
The kernel compiles but I have 1 unresolved simbole in the via-velocity 
modul
depmod: *** Unresolved symbols in 
/lib/modules/2.4.28-rc2/kernel/drivers/net/via-velocity.o
depmod:         crc_ccitt_R3771b461 

Seby..
> 
> --
> Ueimor
 


____________________________________________________________
SC. FO Comunicatii SRL.
Sebastian Ionita
Administrator Sistem
mobil: 0724 212408
tel fix: 0264 450456 
