From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] phy: add reverse MII PHY connection type
Date: Fri, 31 May 2013 14:17:03 +0100
Message-ID: <CAGVrzcYACqRzqGmP5sYnCzuCSp+erXawesRVFAR5Y9GgErO9aQ@mail.gmail.com>
References: <1369750041-30396-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:54158 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751478Ab3EaNRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 09:17:43 -0400
Received: by mail-pb0-f49.google.com with SMTP id rp8so2197534pbb.36
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 06:17:43 -0700 (PDT)
In-Reply-To: <1369750041-30396-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

2013/5/28 Florian Fainelli <f.fainelli@gmail.com>:
> The PHY library currently does not know about the the reverse MII
> connection type. Add it to the list of supported PHY modes and update
> of_get_phy_mode() to support it and look for the string "rev-mii".

You seem to have applied other phylib related patches, just wondering
if this one got forgotten?

Thanks!
--
Florian
