From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] filter: do not output bpf image address for
 security reason
Date: Fri, 17 May 2013 19:55:56 -0700
Message-ID: <1368845756.3301.145.camel@edumazet-glaptop>
References: <1368833499.3301.126.camel@edumazet-glaptop>
	 <1368839478.3469.70.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:34902 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757328Ab3ERCz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 22:55:58 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro8so3819835pbb.41
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 19:55:58 -0700 (PDT)
In-Reply-To: <1368839478.3469.70.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-05-18 at 02:11 +0100, Ben Hutchings wrote:

> Not "%pK"?
> 

Yes, thanks for the suggestion.
