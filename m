From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Bug in netlink_bind
Date: Thu, 29 Jan 2015 10:40:35 +0100
Message-ID: <20150129094035.GA3468@salvia>
References: <20150128234646.GA23945@ycc.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ivan Delalande <colona@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51285 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760713AbbA2Jhb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2015 04:37:31 -0500
Content-Disposition: inline
In-Reply-To: <20150128234646.GA23945@ycc.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 29, 2015 at 12:46:46AM +0100, Ivan Delalande wrote:
> Hi,
>=20
> I=E2=80=99ve been trying to debug some of our tests that began failin=
g when
> upgrading to 3.18. Our actual failure is caused by the condition adde=
d
> in commit 97840cb to nfnetlink_bind but the bug has probably been
> introduced by 0329274.

Will resend this patch asap:

http://patchwork.ozlabs.org/patch/426205/

It didn't apply cleanly last time I submitted it, sorry.
