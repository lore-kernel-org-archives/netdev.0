From: "Francois Barre" <francois.barre@gmail.com>
Subject: Re: [PATCH, RFT] bcm43xx: AccessPoint mode
Date: Wed, 28 Jun 2006 21:50:59 +0200
Message-ID: <fd8d0180606281250p1eb7d69dh49c0ecc8002a36c5@mail.gmail.com>
References: <200606191107.34602.mb@bu3sch.de>
	 <fd8d0180606281227m309b0fcr94bc42c4c5247000@mail.gmail.com>
	 <200606282139.41441.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	"Alexander Tsvyashchenko" <lists@ndl.kiev.ua>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:46162 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S1751129AbWF1TvB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 15:51:01 -0400
Received: by wr-out-0506.google.com with SMTP id i24so460124wra
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2006 12:51:00 -0700 (PDT)
To: "Michael Buesch" <mb@bu3sch.de>
In-Reply-To: <200606282139.41441.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>
> Well, I doubt it is a bcm43xx issue. But maybe. Not sure.
>
> Do you run some QoS stuff? Some other quota stuff?
>

Yes, a special QoS rule that cuts off connections from devices that do
not use a GPL driver.
Long life to the penguin !
Soon, my HiFi will cut off the whole drum section of the DRM songs
I'll ask it to play, and I'm thinking about how to teach my oven not
to bake GM Food :-p.

More seriously, no, I do not have any QoS nor quota service running.
Instead, I was more thinking about a beacon at high rates, but I do not have
enough 802.11 knowledge to know what is advertised during connection...
Maybe the netdev guys would have a clue, a tool, or a bright idea ?
