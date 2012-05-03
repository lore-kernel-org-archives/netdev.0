From: Marco Berizzi <pupilla@hotmail.com>
Subject: RE: rx_dropped packets stop with tcpdump running
Date: Thu, 3 May 2012 13:08:25 +0200
Message-ID: <DUB108-W3055C086AE5AF99FC1FC37B22F0@phx.gbl>
References: <DUB108-W3E0658169335663BE7574B23D0@phx.gbl>,<1334841865.2395.177.camel@edumazet-glaptop>,<1334842088.2395.178.camel@edumazet-glaptop>,<061C8A8601E8EE4CA8D8FD6990CEA8910FF2D23F@ORSMSX102.amr.corp.intel.com>,<DUB108-W45246BF22ED8BAB93B78C8B2220@phx.gbl>
	<4F9179E3.5020507@hp.com>,<DUB108-W57C2F8FCF145C20E3B8BF1B2220@phx.gbl>,<20120422011354.623b08d4.billfink@mindspring.com>,<061C8A8601E8EE4CA8D8FD6990CEA891180CC211@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <brian.haley@hp.com>, <netdev@vger.kernel.org>,
	<eric.dumazet@gmail.com>, <billfink@mindspring.com>
To: <tushar.n.dave@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dub0-omc4-s29.dub0.hotmail.com ([157.55.2.104]:30857 "EHLO
	dub0-omc4-s29.dub0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752846Ab2ECLI1 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 May 2012 07:08:27 -0400
In-Reply-To: <061C8A8601E8EE4CA8D8FD6990CEA891180CC211@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: tushar.n.dave@intel.com

> Looking at the eeprom dump you provided, looks like this issue may get fixed by eeprom update.
> Would you please try eeprom update script, fixeep-82574_83.sh , from
> https://sourceforge.net/projects/e1000/files/e1000e%20stable/eeprom_fix_82574_or_82583/

Hi Dave,

Sorry for the huge delay.
I have applied the update, but I see the dropped packets.
 		 	   		  