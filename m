From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [next PATCH 0/5] net: tcp: DCTCP congestion control algorithm
Date: Tue, 13 May 2014 11:34:29 +0200
Message-ID: <CAPh34mf-nRwyA0LmSwJXy_e4yqMxZ2BEJFz+3LTW_Po91fY5fw@mail.gmail.com>
References: <1399928384-24143-1-git-send-email-fw@strlen.de>
	<CAHA+R7O7yGaMJ+e=nrTmvt+wK7h0kF9okZPTzGseJZa1PiJg9Q@mail.gmail.com>
	<20140512214515.7eb085af@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <cwang@twopensource.com>,
	Florian Westphal <fw@strlen.de>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>, lars@netapp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:35576 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932701AbaEMJea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 05:34:30 -0400
Received: by mail-vc0-f182.google.com with SMTP id la4so83306vcb.41
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 02:34:29 -0700 (PDT)
In-Reply-To: <20140512214515.7eb085af@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some IETF background: IETF Meeting 79 (Beijing) Microsoft employees
presented DCTCP with the intention to standardize DCTCP. The rough
consensus was the DCTCP is datacenter specific, thus closed door
technique and in the result not of broader interest for TCPM working
group. Further effort slowed down quickly.

Last IETF meeting in London (IETF 89) Lars Eggert (cc'ed him) picked
up DCTCP again. My impression was that the willing to adopt or work on
DCTCP was limited (the way I see it) but not definitely buried.

The IPR statement licence it under Royalty-Free, Reasonable and
Non-Discriminatory licence.

Hagen
