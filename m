From: Tim Harvey <tharvey@gateworks.com>
Subject: Re: [PATCH] I.MX6: Fix Ethernet PHY mode on Ventana boards
Date: Wed, 9 Dec 2015 13:53:04 -0800
Message-ID: <CAJ+vNU1YbAbb5X68YBsonEQvck2Fg-YRq_4utGcSzn03rV27sQ@mail.gmail.com>
References: <m3egeyct8o.fsf@t19.piap.pl>
	<20151208.122447.863577308058835164.davem@davemloft.net>
	<m3vb88b270.fsf@t19.piap.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Krzysztof_Ha=C5=82asa?= <khalasa@piap.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:34359 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410AbbLIVxF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 16:53:05 -0500
Received: by ioir85 with SMTP id r85so75029414ioi.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 13:53:04 -0800 (PST)
In-Reply-To: <m3vb88b270.fsf@t19.piap.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 8, 2015 at 9:50 PM, Krzysztof Ha=C5=82asa <khalasa@piap.pl>=
 wrote:
> David Miller <davem@davemloft.net> writes:
>
>> Since this only touched DT files in the ARM platform code, maybe
>> the ARM tree is the best path for this patch rather than mine?
>
> I think so.
>
> Tim, would you like to handle this patch yourself, or should I send i=
t
> to the ARM contacts?

Krzysztof,

Go ahead and send it. You can add my:

Acked-by: Tim Harvey <tharvey@gateworks.com>

I know Shawn would be happy to pick this up as well as he has an
imx-fixes tree:
http://git.kernel.org/cgit/linux/kernel/git/shawnguo/linux.git/log/?h=3D=
imx/soc

Tim
