From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: [PATCH net v2 0/1] Re: ematch: Fix the matching of inverted
 containers (again).
Date: Fri, 3 Oct 2014 15:44:02 +0200
Message-ID: <20141003134402.GA26399@zenon.in.qult.net>
References: <20141003080600.GA13146@zenon.in.qult.net>
 <542E9505.8010805@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:55165 "EHLO qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751648AbaJCNo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 09:44:26 -0400
Received: from zenon.in.qult.net ([192.168.64.1])
	by qult.net with esmtpsa (TLS1.2:DHE_RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1Xa39P-0000Ut-9R
	for netdev@vger.kernel.org; Fri, 03 Oct 2014 15:44:03 +0200
Received: from ig by zenon.in.qult.net with local (Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1Xa39O-0007GE-JO
	for netdev@vger.kernel.org; Fri, 03 Oct 2014 15:44:02 +0200
Content-Disposition: inline
In-Reply-To: <542E9505.8010805@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 03, 2014 at 04:22:29PM +0400, thus spake Sergei Shtylyov:
>    The kernel style dictates that an *if* statement should have {}
> in all its arms, if it has {} in at least one of the arms.

Hi,

Thanks for your kind remark.  Fixed patch follows.

Ignacy Gaw=EAdzki (1):
  ematch: Fix early ending of inverted containers.

 net/sched/ematch.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--=20
1.9.1
