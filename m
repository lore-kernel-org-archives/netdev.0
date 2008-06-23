From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH] hfsc: add link layer overhead adaption
Date: Mon, 23 Jun 2008 22:15:22 +0300
Message-ID: <20080623221522.jqh110t8o4cgss4o@hayate.ip6>
References: <20080623102514.15821.13979.stgit@fate.lan>
	<485F81B2.7000107@trash.net> <20080623142417.9gxuu3y9r4084s4c@hayate.ip6>
	<485F889E.1050901@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=UTF-8;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:43836 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbYFWTPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 15:15:25 -0400
In-Reply-To: <485F889E.1050901@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting Patrick McHardy <kaber@trash.net>:

>>
>> So would it be better if I add 'length table' to kernel&userspace   
>> and use it instead?
>
> Yes, I even posted an unfinished patch for this one or two years
> ago, in response to the overhead calculation patches for HTB etc.
>
> I can't find it right now, but haven't tried too hard. It was
> called qdisc STABs (for size tables), you should be able to find
> it in the archives.

Well, my LTAB didn't end up being exactly same your earlier STAB, but  
I renamed LTAB to STAB as it sounds better. Hope you don't mind :]


