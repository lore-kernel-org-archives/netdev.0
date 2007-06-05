From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC RTNETLINK 00/09]: Netlink link creation API
Date: Tue, 05 Jun 2007 18:00:19 -0400
Message-ID: <1181080819.4062.10.camel@localhost>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, xemul@sw.ru,
	ebiederm@xmission.com, tgraf@suug.ch
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.232]:2371 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759965AbXFEWAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 18:00:23 -0400
Received: by nz-out-0506.google.com with SMTP id n1so1526194nzf
        for <netdev@vger.kernel.org>; Tue, 05 Jun 2007 15:00:23 -0700 (PDT)
In-Reply-To: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


All patches looked really good. speaking for the ifb stuff, a definete
ACK. 
The only thing that threw me off for a sec was the naming convention for
"type" referenced via IFLA_INFO_NAME because it seems to be colliding
semantic with dev->type and dev->name as in IFLA_NAME and  
ifi_type ifinfomsg.
But i cant come with a better noun. 

Good stuff, nevertheless  

cheers,
jamal

