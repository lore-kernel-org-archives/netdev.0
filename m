From: Anirban Sinha <asinha@zeugmasystems.com>
Subject: RFC 5482
Date: Fri, 6 Nov 2009 10:49:46 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0911061041540.30985@sleet.zeugmasystems.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeugmasystems.com ([70.79.96.174]:17503 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753165AbZKFStr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 13:49:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

I am just wondering if the linux TCP/IP stack supports the RFF 5482 (TCP user
timeout option)?

http://www.faqs.org/rfcs/rfc5482.html

A grep across the source and a search in the git repository does not yield any
useful information.

Also as a side question, i am wondering if it's possible to change/control the
TCP three-way handshake timeout (reception of the last SYN_ACK) on a
per-connection basis.

Thanks,

Ani

