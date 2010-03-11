From: Vito Mattera <vito.m@cost.it>
Subject: vlan JMicron Technologies, Inc. JMC250 PCI Express Gigabit Ethernet
Date: Thu, 11 Mar 2010 17:04:57 +0100
Message-ID: <4B9914A9.2050207@cost.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipcop.cost.it ([213.156.62.142]:40532 "EHLO webmail.cost.it"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933136Ab0CKQMJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Mar 2010 11:12:09 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by webmail.cost.it (Postfix) with ESMTP id 878781BDAC9
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 17:04:21 +0100 (CET)
Received: from webmail.cost.it ([127.0.0.1])
	by localhost (webmail.cost.it [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id j6gXC3lbhytR for <netdev@vger.kernel.org>;
	Thu, 11 Mar 2010 17:04:19 +0100 (CET)
Received: from [192.168.100.105] (mailz.fbs.it [85.18.70.164])
	by webmail.cost.it (Postfix) with ESMTPSA id 7C2941BAA10
	for <netdev@vger.kernel.org>; Thu, 11 Mar 2010 17:04:19 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm trying to add vlan using the network adapter  JMC250 in CentOS 5.3
with the driver: kmod-jme-1.0.5-1.el5.elrepo.i686.rpm


when I type the command:
vconfig add eth0 3

I have the following message:


802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
register_vlan_device: Device eth0 has buggy VLAN hw accel

and no vlan is created.

what is my mistake ?

TIA

Best regards

vito mattera


-- 
CoST - Computers Services and Technologies s.r.l.
20137 via Longhi 13 - Milano - Italy
phone : +39 0245446.1 ext. 253
mobile: +39 335275451
fax   : +39 0245446.333

Questo messaggio e i suoi allegati sono indirizzati esclusivamente alle 
persone indicate. La diffusione, copia o qualsiasi altra azione 
derivante dalla conoscenza di queste informazioni sono rigorosamente 
vietate. Qualora abbiate ricevuto questo documento per errore siete 
cortesemente pregati di darne immediata comunicazione al mittente e di 
provvedere alla sua distruzione. Grazie.

This e-mail and any attachment are confidential and may contain 
privileged information intended for the addressee(s) only.
Dissemination, copying, printing or use by anybody else is unauthorized. 
If you are not the intended recipient, please delete this message and 
any attachment and advise the sender by return e-mail. Thank you

