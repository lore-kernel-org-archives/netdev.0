From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: Network protocol (IP,IPv6,...) and TC actions
Date: Tue, 13 Apr 2010 19:31:07 +0200
Message-ID: <4BC4AA5B.8040901@computer.org>
References: <20100411190845.GA18383@n7mm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?ISO-8859-1?Q?Gr=E9goire_Baron?= <baronchon@n7mm.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay006.isp.belgacom.be ([195.238.6.172]:64400 "EHLO
	mailrelay006.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751143Ab0DMRcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 13:32:03 -0400
In-Reply-To: <20100411190845.GA18383@n7mm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gr=E9goire Baron wrote:
> As this .protocol member seems to be used at different moments when a
> packet is received, forwared or sent, and could contain something lik=
e
> ETH_P_8021Q which isn't a network protocol Id, can we say the struct
> sk_buff .protocol member is guaranteed to contain a network protocol =
Id
> in the struct sb_buff used in the TC action executions ?

Gr=E9goire,

I suggest that you ask your question on the netdev mailing list (netdev=
@vger.kernel.org).

Cheers, Jan
