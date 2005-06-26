From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: BCM5721(tg3)&MSI
Date: Sun, 26 Jun 2005 12:29:15 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0506261219580.2421@bizon.gios.gov.pl>
References: <B1508D50A0692F42B217C22C02D84972067F0843@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1989374933-1119781755=:2421"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972067F0843@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1989374933-1119781755=:2421
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Sat, 25 Jun 2005, Michael Chan wrote:

>
> Krzysztof Oledzki wrote:
>> Which BCM chips support MSI? I have a mainbord with two
>> BCM5721, it seems
>> both support MSI (Message Signalled Interrupts entry in
>> Capabilities) but
>> with 2.6.12.1 tg3 driver does not enable it. Why?
>>
>> 04:00.0 Ethernet controller: Broadcom Corporation NetXtreme
>> BCM5721 Gigabit Ethernet PCI Express (rev 11)
>
> MSI is only enabled on 5721 C0 and newer chips that have fully
> working MSI. You are using 5721 B1.
Oh, I see... BTW: What is wrong with AX/BX revisions?

Best regards,

 =09=09=09Krzysztof Ol=EAdzki
---187430788-1989374933-1119781755=:2421--
