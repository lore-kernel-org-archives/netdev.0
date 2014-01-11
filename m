From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH net-next] IPv6: enable TCP to use an anycast address
Date: Sat, 11 Jan 2014 16:46:49 +0400
Message-ID: <CAMrnHh6pBYMLn+zsR2P_oo8KufJq7Dkjm-cSq2N2Hi638yrUog@mail.gmail.com>
References: <1389442059-3047-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:50646 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbaAKMqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 07:46:50 -0500
Received: by mail-ig0-f173.google.com with SMTP id ut6so1603755igb.0
        for <netdev@vger.kernel.org>; Sat, 11 Jan 2014 04:46:49 -0800 (PST)
In-Reply-To: <1389442059-3047-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I am just curious: since when is TCP allowed to use anycast addresses?

Alexey Kuznetsov
