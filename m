From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: Re: [PATCH net-next] ipheth: Add support for iPad 2 and iPad 3
Date: Tue, 3 Jun 2014 21:38:00 +0200
Message-ID: <CAKfDRXiEhGg0KAQr6rLbaR6ee0tZedAOpHWsKBQaZSdG8UbheA@mail.gmail.com>
References: <1401445020-14027-1-git-send-email-kristian.evensen@gmail.com>
	<20140602.161217.1136496149550873922.davem@davemloft.net>
	<CAKfDRXiQvteVXwHMaQxKbtDTb7v0OAx3dyN0WF6dTxKveN8GBg@mail.gmail.com>
	<EE5FBFB4-E1DD-47BF-8169-FCC4F51839D5@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: "Pritesh Kothari (pritkoth)" <pritkoth@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:54126 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753781AbaFCTiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 15:38:01 -0400
Received: by mail-yk0-f182.google.com with SMTP id 9so5261395ykp.41
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 12:38:01 -0700 (PDT)
In-Reply-To: <EE5FBFB4-E1DD-47BF-8169-FCC4F51839D5@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 3, 2014 at 8:31 PM, Pritesh Kothari (pritkoth)
<pritkoth@cisco.com> wrote:
> http://www.linux-usb.org/usb.ids says this, if it helps.
>
>         12a2  iPad 2 (3G; 64GB)
>         12a3  iPad 2 (CDMA)
>         12a4  iPad 3 (wifi)
>         12a5  iPad 3 (CDMA)
>         12a6  iPad 3 (3G, 16 GB)
>         12a9  iPad 2
>         12ab  iPad 4 (WiFi, 32GB)

Thank you very much for the reference. I will patch in support for the
missing devices as soon as I can confirm the devices support
tethering.

-Kristian
