From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Re: [PATCH net-next] r8169: Support for byte queue limits
Date: Mon, 19 Dec 2011 10:53:43 +0100
Message-ID: <CAFdo_mWN3ixQm8BWUy++9T3NvtWHGTnFb-bubL4iM=jygaiRfw@mail.gmail.com>
References: <igorm@etf.rs>
	<1324286878-3950-1-git-send-email-igorm@etf.rs>
	<1324287964.3323.107.camel@edumazet-laptop>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, nic_swsd@realtek.com,
	romieu@fr.zoreil.com, therbert@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:36564 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751296Ab1LSJxs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Dec 2011 04:53:48 -0500
Received: from localhost (avs1.etf.rs [147.91.14.172])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id C718160130
	for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 10:53:47 +0100 (CET)
Received: from mx1.etf.bg.ac.rs ([147.91.14.169])
	by localhost (avs1.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id UtsjllOwq--Q for <netdev@vger.kernel.org>;
	Mon, 19 Dec 2011 10:53:45 +0100 (CET)
Received: from mail-tul01m020-f174.google.com (mail-tul01m020-f174.google.com [209.85.214.174])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx1.etf.bg.ac.rs (Postfix) with ESMTP id 4BBF21200DD
	for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 10:53:45 +0100 (CET)
Received: by obcwo16 with SMTP id wo16so1625106obc.19
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2011 01:53:43 -0800 (PST)
In-Reply-To: <1324287964.3323.107.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> What are the changes in this version, versus prior submissions ?
>

You didn't answer to my comments, so I thought that my version was OK.
I'l change this in a sec.
