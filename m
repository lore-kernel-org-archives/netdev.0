From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Fri, 4 Dec 2015 16:53:00 -0800
Message-ID: <CALx6S36Y4fP9a6U40My+kuhik5THPOjHNYfRrVe8Szte03K7Ew@mail.gmail.com>
References: <1449158374.11080.456996721.69F803D7@webmail.messagingengine.com>
	<CALx6S342OMLB6s7LcmnZP1rnYNUs345Dy1gjYX3JUKqqB_waPA@mail.gmail.com>
	<1449259145.6236.458303617.55CF2C4E@webmail.messagingengine.com>
	<20151204.150633.1744714566987717806.davem@davemloft.net>
	<CAKgT0UepW=VehhXncrAM=tvqrVDD_KOdVJBpwEU+hYTAdMz_dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Linville <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36280 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755525AbbLEAxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 19:53:01 -0500
Received: by iofh3 with SMTP id h3so133714309iof.3
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 16:53:00 -0800 (PST)
In-Reply-To: <CAKgT0UepW=VehhXncrAM=tvqrVDD_KOdVJBpwEU+hYTAdMz_dg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I actually tried to push the generic checksum idea for fm10k back
> during hardware development but ended up losing that battle.  The
> problem is you have to have some customer willing to spend the cash in
> order to get a feature, and the fact is nobody other than Tom has been
> pushing for this.

Very well, it is true that I only represent one user of networking
protocols, grant it a very large one. I will shut up now. If other
USERS want to chime in on what is best I'll certainly listen.
