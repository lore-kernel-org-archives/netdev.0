From: Maz The Northener <mazziesaccount@gmail.com>
Subject: Re: patch "workflow" - what deferred state means?
Date: Wed, 9 Nov 2011 11:57:13 +0200
Message-ID: <CANhJrGN+PdDGDnZaido8Tizc4X4su6E=z-xWJAY4NbNrXG22wA@mail.gmail.com>
References: <CANhJrGNsyD1vsRA4xhgD3KrY9ZcdNOyM4JsM+kf71Pt9KTqh-Q@mail.gmail.com>
	<20111107.141421.1710547287569203789.davem@davemloft.net>
	<CANhJrGMsM7Pc9j0SB4G4Xxym0LLYmtaUq--vyPgt+7HWNz7H0Q@mail.gmail.com>
	<20111107.151954.624621133639707298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Matti Vaittinen <matti.vaittinen@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:33024 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756573Ab1KIJ5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2011 04:57:14 -0500
Received: by pzk2 with SMTP id 2so1257820pzk.1
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2011 01:57:14 -0800 (PST)
In-Reply-To: <20111107.151954.624621133639707298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 7, 2011 at 10:19 PM, David Miller <davem@davemloft.net> wrote:
> From: Maz The Northener <mazziesaccount@gmail.com>
> Date: Mon, 7 Nov 2011 22:08:00 +0200
>
>> I was talking about http://patchwork.ozlabs.org/patch/123407/ and
>> patchwork.ozlabs.org/patch/123406/
>
> This kind of work should be resubmitted when net-next opens back up.
>

I assume now would be correct time, right? If I am correct, net-next
is open now due to linux 3.2-rc1 (If I am wrong, please tell me how I
know when net-next is opened).
So I should resubmit the patches. I just fetched snapshot from
net-next.git at kernel.org, and tried applying the patches. Applying
succeeded but with offset. So should I redo patches on top of some
other kernel, and if so, which one?

-Matti
