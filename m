From: jamal <hadi@cyberus.ca>
Subject: Re: Netlink as an IP Services Protocol to Informational
Date: Thu, 10 Apr 2003 14:25:59 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030410142253.V86925@shell.cyberus.ca>
References: <200304091749.h39Hn6XU029346@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <200304091749.h39Hn6XU029346@marajade.sandelman.ottawa.on.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Question for you, since you are a security expert:
We are having problems deciding whethet TLS needs reliability or whether
it needs connection orientedness.
Connection orientedness is essentially being able to connect and leave
(example TCP SYN,SYNACK,ACK...FIN,FINACK)
Reliability is ensuring delivery i.e Retransmits and keeping state of
dataflow vs ACKs and sequence numbers.

Does TLS just need somehow to setup the connection or does it need both?

cheers,
jamal
