From: Alex Davis <alex14641@yahoo.com>
Subject: Firewall question
Date: Thu, 8 Jun 2006 11:57:12 -0700 (PDT)
Message-ID: <20060608185712.79340.qmail@web50207.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from web50207.mail.yahoo.com ([206.190.38.48]:8824 "HELO
	web50207.mail.yahoo.com") by vger.kernel.org with SMTP
	id S964939AbWFHS5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 14:57:13 -0400
To: netfilter@lists.netfilter.org, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The scenario:
I have a DSL modem in pass through (bridge) mode. The linux firewall/router 
has a single ethernet card.  It is running pppoe. This gives two interfaces: 
eth0 and ppp0. The firewall is running iptables. There are several machines 
behind the firewall.

Problem:
I've been told that if someone whose public IP address is on the same
network subnet as mine were to get my mac address, (s)he could bypass
the firewall and talk directly to the machines behind it.

Is this true?

Thanks.


I code, therefore I am

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
