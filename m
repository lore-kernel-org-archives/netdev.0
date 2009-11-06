From: Anirban Sinha <asinha@zeugmasystems.com>
Subject: Re: RFC 5482
Date: Fri, 6 Nov 2009 15:08:31 -0800 (PST)
Message-ID: <Pine.LNX.4.64.0911061507190.30985@sleet.zeugmasystems.local>
References: <Pine.LNX.4.64.0911061041540.30985@sleet.zeugmasystems.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeugmasystems.com ([70.79.96.174]:15409 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758813AbZKFXI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 18:08:26 -0500
In-Reply-To: <Pine.LNX.4.64.0911061041540.30985@sleet.zeugmasystems.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

oops, sorry. Typo.

> Also as a side question, i am wondering if it's possible to change/control the
> TCP three-way handshake timeout (reception of the last SYN_ACK) on a
> per-connection basis.

It will be the timeout on the server side between SYN-ACK and the last ACK
from the peer.
