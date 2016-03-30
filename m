From: Peter Korsgaard <peter@korsgaard.com>
Subject: Re: am335x: no multicast reception over VLAN
Date: Wed, 30 Mar 2016 21:47:32 +0200
Message-ID: <878u0z9297.fsf@dell.be.48ers.dk>
References: <CAGm1_ktOqB4QBMy2G4XeHTkaP+WvG8GOc8maVv3dDoxM+-F+ZA@mail.gmail.com>
	<56F9FDD0.8030504@ti.com>
	<CAGm1_ksxRPCAqx4n5gbsARSYeF116BT7r8cC6=1QYnEsYRxpVw@mail.gmail.com>
	<56FA616C.9080502@ti.com>
	<CAGm1_ksvEdk-mF-hW4o5+bri6J6sMgnQQVD3j-e7xm6PsP8k0A@mail.gmail.com>
	<56FA78AA.4030402@ti.com> <56FB6543.9060904@ti.com>
	<CAGm1_kvXA4egrK8-oCedYjvPm7BhJdy_w-5ON24snYdKiN3K7g@mail.gmail.com>
	<56FC0431.5000106@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yegor Yefremov <yegorslists@googlemail.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-omap\@vger.kernel.org" <linux-omap@vger.kernel.org>,
	<drivshin@allworx.com>, <ml@markusgrimm.de>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34688 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbcC3Trf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 15:47:35 -0400
In-Reply-To: <56FC0431.5000106@ti.com> (Mugunthan V. N.'s message of "Wed, 30
	Mar 2016 22:22:01 +0530")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>>>> "Mugunthan" == Mugunthan V N <mugunthanvnm@ti.com> writes:

Hi,

 > You had received these packets as tcpdump will enable promiscuous mode
 > so that you receive all the packets from the wire.

FYI, you can use the -p option to tcpdump to not put the interface into
promiscuous mode.

-- 
Bye, Peter Korsgaard
