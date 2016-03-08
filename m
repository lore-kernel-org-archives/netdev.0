From: subashab@codeaurora.org
Subject: Re: 4.1.12 kernel crash in rtnetlink_put_metrics
Date: Tue, 8 Mar 2016 04:27:00 -0000
Message-ID: <475c3698bd7e6c504711e74e60808578.squirrel@us.codeaurora.org>
References: <563A2BA7.9080202@seti.kr.ua> <563A62C8.3030901@iogearbox.net>
    <6dc33a912af28968363ec472b69bdd5c@codeaurora.org>
    <56DE112D.5050603@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Andrew" <nitr0@seti.kr.ua>, netdev@vger.kernel.org, kafai@fb.com
To: "Daniel Borkmann" <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51052 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411AbcCHE1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 23:27:02 -0500
In-Reply-To: <56DE112D.5050603@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmm, if it was 4.1.X like in original reporter case, I might have thought
> something like commit 0a1f59620068 ("ipv6: Initialize rt6_info properly
> in ip6_blackhole_route()") ... any chance on reproducing this on a latest
> kernel?
>

Unfortunately, I haven't encountered a similar crash on newer kernels as of now.
