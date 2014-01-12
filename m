From: "Bob Falken" <NetFestivalHaveFun@gmx.com>
Subject: Re: Multicast routing stops functioning after 4G multicast packets
 recived.
Date: Sun, 12 Jan 2014 01:25:54 +0100
Message-ID: <20140112002554.18070@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: "Julian Anastasov" <ja@ssi.bg>, netdev@vger.kernel.org,
	kaber@trash.net, tgraf@suug.ch, eric.dumazet@gmail.com
To: "Hannes Frederic Sowa" <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:55065 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750857AbaALAZz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Jan 2014 19:25:55 -0500
Received: from mailout-eu.gmx.com ([10.1.101.210]) by mrigmx.server.lan
 (mrigmx002) with ESMTP (Nemesis) id 0MJqWY-1W3FKw3JO0-001CRB for
 <netdev@vger.kernel.org>; Sun, 12 Jan 2014 01:25:54 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Hannes, The updated patch you posted on the 7th worked as expected (as far as i know, did not have any obvious issues.) :-)

I'll run a full test starting on Monday/Thursday, and report back after I have reached 2^32 RX packets. 

I will then run a longer test (3-4 weeks), and also check that TX is ok after reaching 2^32 packets. 

Thanks again for all the help.

Best Regards.
