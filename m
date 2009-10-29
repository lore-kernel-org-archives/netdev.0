From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net,socket: introduce build_sockaddr_check helper to
	catch overflow at build time
Date: Thu, 29 Oct 2009 17:50:10 +0300
Message-ID: <20091029145010.GA5463@lenovo>
References: <20091023214306.GA30616@lenovo> <20091024.061209.39469983.davem@davemloft.net> <20091024163226.GA5204@lenovo> <20091029.030019.44832583.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f209.google.com ([209.85.219.209]:39550 "EHLO
	mail-ew0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524AbZJ2OuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 10:50:10 -0400
Received: by ewy5 with SMTP id 5so71474ewy.37
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2009 07:50:14 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20091029.030019.44832583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[David Miller - Thu, Oct 29, 2009 at 03:00:19AM -0700]
...
| > Eventually inet_getname is switched to use DECLARE_SOCKADDR
| > (to show example of usage).
| > 
| > Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
| 
| I like this, applied to net-next-2.6, thanks!
| 

Thanks David. I'll handle other protocols in a couple
of days.

	-- Cyrill
