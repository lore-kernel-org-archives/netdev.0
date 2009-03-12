From: Pantelis Koukousoulas <pktoss@gmail.com>
Subject: Re: [PATCH] Make virtio_net support carrier detection
Date: Thu, 12 Mar 2009 15:10:56 +0200
Message-ID: <1295ed070903120610u69dd78b3s7c02c5c5205f550a@mail.gmail.com>
References: <1295ed070903120547q431b5b40n71b8d2e98719e18d@mail.gmail.com>
	 <20090312.055235.56926675.davem@davemloft.net>
	 <1295ed070903120558u33d633f4v1622ef56a06066a0@mail.gmail.com>
	 <20090312.060321.93794599.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, rusty@rustcorp.com.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:13714 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753790AbZCLNK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 09:10:59 -0400
Received: by ey-out-2122.google.com with SMTP id 25so107466eya.37
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2009 06:10:56 -0700 (PDT)
In-Reply-To: <20090312.060321.93794599.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 3:03 PM, David Miller <davem@davemloft.net> wrote:
> From: Pantelis Koukousoulas <pktoss@gmail.com>
> Date: Thu, 12 Mar 2009 14:58:28 +0200
>
>> > If the link is always on, you should make that explicit by providing
>> > a link state handler, and making sure it always returns true.
>>
>> So, you agree that my patch that does exactly that is correct ?
>
> Yes, absolutely.
>

Great, because the point I was arguing about was exactly what you
wrote on the previous mail :)

Thanks,
Pantelis
