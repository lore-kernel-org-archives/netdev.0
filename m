From: "Anand Kumria" <wildfire@progsoc.org>
Subject: Re: OLPC (One Laptop Per Child) Developer's program.
Date: Sun, 4 Jun 2006 13:17:16 +0000 (UTC)
Message-ID: <e5umgs$lfj$1@sea.gmane.org>
References: <1149025377.30703.141.camel@localhost.localdomain>
	<1149335345.5053.177.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:64717 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S1751482AbWFDNRi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2006 09:17:38 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1FmsTz-0002r7-Bb
	for netdev@vger.kernel.org; Sun, 04 Jun 2006 15:17:31 +0200
Received: from 80-41-95-98.dynamic.dsl.as9105.com ([80.41.95.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2006 15:17:31 +0200
Received: from wildfire by 80-41-95-98.dynamic.dsl.as9105.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2006 15:17:31 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 03 Jun 2006 12:49:05 +0100, David Woodhouse wrote:

> On Tue, 2006-05-30 at 17:42 -0400, Jim Gettys wrote:
>> As you know, we've said we were going to have a developer's program. You
>> can find more information, including how to apply for boards at:
>> 
>> http://wiki.laptop.org/index.php/Developers_Program
>> 
>> Note that these are bare PC prototype boards, not packaged machines.
>>                            Jim Gettys
> 
> ObNetdev: 
> 
> One thing we really need is NAT-PT or an equivalent for allowing access
> to the Legacy Internet from IPv6-only hosts. As soon as I finish playing
> with JFFS2 improvements, I plan to start looking at that.

Wouldn't miredo mostly fit the bill? It won't get through Symmetric NATs
(by design) but those are supposed to be uncommon.

Cheers,
Anand

