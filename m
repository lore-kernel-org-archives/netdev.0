From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: am335x: no multicast reception over VLAN
Date: Thu, 31 Mar 2016 12:07:15 +0530
Message-ID: <56FCC59B.70209@ti.com>
References: <CAGm1_ktOqB4QBMy2G4XeHTkaP+WvG8GOc8maVv3dDoxM+-F+ZA@mail.gmail.com>
 <56F9FDD0.8030504@ti.com>
 <CAGm1_ksxRPCAqx4n5gbsARSYeF116BT7r8cC6=1QYnEsYRxpVw@mail.gmail.com>
 <56FA616C.9080502@ti.com>
 <CAGm1_ksvEdk-mF-hW4o5+bri6J6sMgnQQVD3j-e7xm6PsP8k0A@mail.gmail.com>
 <56FA78AA.4030402@ti.com> <56FB6543.9060904@ti.com>
 <CAGm1_kvXA4egrK8-oCedYjvPm7BhJdy_w-5ON24snYdKiN3K7g@mail.gmail.com>
 <56FC0431.5000106@ti.com> <878u0z9297.fsf@dell.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Yegor Yefremov <yegorslists@googlemail.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	<drivshin@allworx.com>, <ml@markusgrimm.de>
To: Peter Korsgaard <peter@korsgaard.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:34420 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755832AbcCaGha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2016 02:37:30 -0400
In-Reply-To: <878u0z9297.fsf@dell.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 31 March 2016 01:17 AM, Peter Korsgaard wrote:
>>>>>> "Mugunthan" == Mugunthan V N <mugunthanvnm@ti.com> writes:
> 
> Hi,
> 
>  > You had received these packets as tcpdump will enable promiscuous mode
>  > so that you receive all the packets from the wire.
> 
> FYI, you can use the -p option to tcpdump to not put the interface into
> promiscuous mode.
> 

Thanks for the information Peter Korsgaard.

Yegor, can you provide tcpdump using -p as well in Grygorii commands.

Regards
Mugunthan V N
