From: "Naveen B N (nbn)" <nbn@cisco.com>
Subject: How to get the port values
Date: Thu, 10 Nov 2011 18:55:30 +0530
Message-ID: <A2354B6A9F807641B21EEABD666ECEEA01CCF3BC@XMB-BGL-416.cisco.com>
References: <1320417988.69298.YahooMailNeo@web126013.mail.ne1.yahoo.com>  <1320423860.16609.4.camel@edumazet-laptop>  <1320482392.98040.YahooMailNeo@web126003.mail.ne1.yahoo.com> <1320485406.16908.4.camel@edumazet-laptop> <1320922725.65072.YahooMailNeo@web126002.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ams-iport-4.cisco.com ([144.254.224.147]:45237 "EHLO
	ams-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606Ab1KJNfe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2011 08:35:34 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1320922725.65072.YahooMailNeo@web126002.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

How can i get an access to port values from sock *sk in the 
Function rawv6_sendmsg before xfrm_lookup in file /net/ipv6/raw.c .
In case the application itself is including the headers [ IP , UDP  ].
I want to bypass the port 500 for my application from IPsec.

Regards
Naveen
