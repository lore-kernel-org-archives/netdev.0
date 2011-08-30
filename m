From: Adrian Chadd <adrian@freebsd.org>
Subject: Re: BQL crap and wireless
Date: Tue, 30 Aug 2011 09:48:27 +0800
Message-ID: <CAJ-VmokkkZ8Bj3TetjePVc6fZK1NtAOq7+6Qri6N-8+nppBZGg@mail.gmail.com>
References: <CAB=NE6VuP=AvYiJsYn_Noc1u0Q=jvQPutHRANdSiLP2v48ogfg@mail.gmail.com>
	<CAB=NE6VwWu5+Hk7=3ghkgiXss9kCqGyS-RWPYtyHRhDsx5r2rA@mail.gmail.com>
	<CAA93jw7c+Nxc6ZbWZWsQ+F78AoPWU=quSRaOUpT0yRcwJOXsGQ@mail.gmail.com>
	<4E5C3B47.1050809@freedesktop.org>
	<CAJ-Vmom_EwR31Z6r4VpSiKTwE+YXwmRwtwurzr5VUX6nnC67fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	Dave Taht <dave.taht@gmail.com>,
	Tom Herbert <therbert@google.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Andrew McGregor <andrewmcgr@gmail.com>,
	Matt Smith <smithm@qca.qualcomm.com>,
	Kevin Hayes <hayes@qca.qualcomm.com>,
	Derek Smithies <derek@indranet.co.nz>, netdev@vger.kernel.org
To: Jim Gettys <jg@freedesktop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:32852 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab1H3Bs1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2011 21:48:27 -0400
In-Reply-To: <CAJ-Vmom_EwR31Z6r4VpSiKTwE+YXwmRwtwurzr5VUX6nnC67fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.. Whilst knee-deep in it all, I should also mention things like
"transmission opportunity/beacon transmit time being enforced by
hardware" - ie, where the hardware stops a packet TX from occuring
because it would exceed the programmed TXOP window, or because it
would interfere with an upcoming beacon TX from the hostap.

Another 2c,


Adrian
