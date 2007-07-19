From: andrei radulescu-banu <iubica2@yahoo.com>
Subject: Re: Linux, tcpdump and vlan
Date: Thu, 19 Jul 2007 09:02:38 -0700 (PDT)
Message-ID: <997818.30021.qm@web56615.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ascii
Cc: Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web56615.mail.re3.yahoo.com ([66.196.97.59]:38607 "HELO
	web56615.mail.re3.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932307AbXGSQCp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 12:02:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One additional thought: with the proposed changes in my prev message, the driver can be set to hw vlan accelerated mode, even if no vlan interfaces are configured. We would not have to switch hw vlan accelerated mode anymore, when vlan interfaces are created or destroyed.






       
____________________________________________________________________________________
Be a better Heartthrob. Get better relationship answers from someone who knows. Yahoo! Answers - Check it out. 
http://answers.yahoo.com/dir/?link=list&sid=396545433
