From: Ignacy Gawedzki <ignacy.gawedzki@green-communications.fr>
Subject: Re: Attempt to auto-load em_cmp.ko results in negative module refcnt
Date: Mon, 16 Feb 2015 16:03:30 +0100
Message-ID: <20150216150329.GB16798@zenon.in.qult.net>
References: <20150216105912.GA16798@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:58053 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbbBPPD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2015 10:03:56 -0500
Received: from zenon.in.qult.net ([192.168.64.1] helo=zenon)
	by mail.qult.net with esmtps (TLS1.2:RSA_AES_128_CBC_SHA1:128)
	(Exim 4.82)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YNNCs-0005sA-T9
	for netdev@vger.kernel.org; Mon, 16 Feb 2015 16:03:30 +0100
Received: from ig by zenon with local (Exim 4.84_RC1)
	(envelope-from <ignacy.gawedzki@green-communications.fr>)
	id 1YNNCs-0001NE-1m
	for netdev@vger.kernel.org; Mon, 16 Feb 2015 16:03:30 +0100
Content-Disposition: inline
In-Reply-To: <20150216105912.GA16798@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 16, 2015 at 11:59:12AM +0100, thus spake Ignacy Gawedzki:
> This has been broken pretty recently, I'm currently attempting a git =
bisect on
> this.

Okay, the bisect tells this appeared with
e513cc1c07e2ab93a4514eec9833e031df3e30bb, FWIW.

--=20
Ignacy Gaw=EAdzki
R&D Engineer
Green Communications
