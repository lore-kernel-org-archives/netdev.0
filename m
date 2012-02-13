From: Neal Cardwell <ncardwell@google.com>
Subject: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Mon, 13 Feb 2012 17:51:20 -0500
Message-ID: <CADVnQykiHqmjCSofbMVL13iZaPhuJwRDUqPoCw8f2ynzpfdQTA@mail.gmail.com>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	<1329164293.2523.0.camel@edumazet-laptop>
	<1329167638.2523.2.camel@edumazet-laptop>
	<3490386.xy2kafBK9b@localhost.localdomain>
	<1329173056.2523.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:58667 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753786Ab2BMWvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 17:51:21 -0500
Received: by qadc10 with SMTP id c10so1954452qad.19
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2012 14:51:20 -0800 (PST)
In-Reply-To: <1329173056.2523.14.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Could you also please post a tcpdump of a "good" transfer on a 3.1.x
kernel to the same server? It would be nice to make sure the options
and advertised windows are the same in both cases.

neal
