From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] netdev: stop Features changed message
Date: Fri, 20 May 2011 18:21:33 +0200
Message-ID: <BANLkTikmcR+iFsUZecyLztYuGCv5-s7aLg@mail.gmail.com>
References: <20110520090208.7709bec3@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:35151 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934520Ab1ETQVz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2011 12:21:55 -0400
Received: by qwk3 with SMTP id 3so1946681qwk.19
        for <netdev@vger.kernel.org>; Fri, 20 May 2011 09:21:54 -0700 (PDT)
In-Reply-To: <20110520090208.7709bec3@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/20 Stephen Hemminger <shemminger@vyatta.com>:
> The new in 2.6.39 message "Features changed:" occurs a lot
> on many configurations. It provides information to driver developers
> but is not user friendly. Printing out hex values is just confusing.
> Reduce priority so that it doesn't show up unless debugging.

The same patch is already in net-next:
604ae14ffb6d75d6eef4757859226b758d6bf9e3. Wasn't it meat for
net/stable back then?

Best Regards,
Micha=C5=82 Miros=C5=82aw
