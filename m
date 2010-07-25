From: AgentC <agentc23@yahoo.de>
Subject: linux and 2 LAN-cards ?
Date: Mon, 26 Jul 2010 00:36:35 +0200
Message-ID: <i2ieav$k2s$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:47245 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751531Ab0GYWkG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jul 2010 18:40:06 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Od9rX-0002aY-AM
	for netdev@vger.kernel.org; Mon, 26 Jul 2010 00:40:03 +0200
Received: from dyndsl-080-228-183-233.ewe-ip-backbone.de ([80.228.183.233])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 00:40:03 +0200
Received: from agentc23 by dyndsl-080-228-183-233.ewe-ip-backbone.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 00:40:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm a linux newbie and have some configuration-probs with the network.
could anyone give some hints to get it working?

normally I used mainboard internal LAN for modemrouter / webaccess only.
out of some configurationproblems I had to remove my additional netgear-
router which was used as hub for my additional terminal-workstations
in my flat. but now it is impossible to do that anymore cause my
webserver will not work when the netgear is between the DSL-modemrouter
and my server. so I decided to try it out with a second LAN card (PCI)
where I tried to connect the netgear as hub.

but what happened was, that all outside access wasn't possible anymore
(for example ping google.de) but access to the dsl-modemrouter was 
possible. ping connection to the netgear was not possible.

what happened? have the both network adapters conflicts on the PCI-bus?
or is this a configuration problem within linux config ?

can anyone tell me what went wrong and how to fix that problem ?

sincerly,
Ralf M.




