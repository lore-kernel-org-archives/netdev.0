From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Wed, 27 Oct 2010 01:35:06 -0700
Message-ID: <AANLkTikTT5ie-R61rA9NucgGi5RBOPpXZLMYQRa_wb7j@mail.gmail.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
	<4CC78F19.9080504@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40601 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754445Ab0J0IfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 04:35:08 -0400
Received: by wyf28 with SMTP id 28so403644wyf.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 01:35:06 -0700 (PDT)
In-Reply-To: <4CC78F19.9080504@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

So how does all this work with privacy addresses, established
connections, and a link flap?
