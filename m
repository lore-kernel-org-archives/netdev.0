From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] wpan: use GFP_ATOMIC instead of GFP_KERNEL
Date: Tue, 05 Feb 2013 10:21:31 -0800
Message-ID: <1360088491.28557.7.camel@edumazet-glaptop>
References: <1360078474-24362-1-git-send-email-alex.aring@gmail.com>
	 <1360080597.28557.5.camel@edumazet-glaptop>
	 <20130205180057.GA1124@x61s.8.8.8.8> <20130205181310.GB1124@x61s.8.8.8.8>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	netdev@vger.kernel.org
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:51781 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753934Ab3BESVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 13:21:33 -0500
Received: by mail-pa0-f42.google.com with SMTP id kq12so287043pab.29
        for <netdev@vger.kernel.org>; Tue, 05 Feb 2013 10:21:33 -0800 (PST)
In-Reply-To: <20130205181310.GB1124@x61s.8.8.8.8>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-05 at 19:13 +0100, Alexander Aring wrote:

> Ahh, you mean to put it on the stack. :-)
> 
> Sorry about that.

No problem ;)
