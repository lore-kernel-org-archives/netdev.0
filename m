From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 1/4] ipip: allow to deactivate the creation of
 fb dev
Date: Tue, 20 Nov 2012 09:30:17 +0100
Message-ID: <50AB3F99.7070701@6wind.com>
References: <1353082456-21234-2-git-send-email-nicolas.dichtel@6wind.com> <20121116082926.1c6cccd2@nehalam.linuxnetplumber.net> <50A66DD3.20807@6wind.com> <20121119.190753.856116050444408241.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:33452 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528Ab2KTIaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 03:30:21 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so1545455eek.19
        for <netdev@vger.kernel.org>; Tue, 20 Nov 2012 00:30:20 -0800 (PST)
In-Reply-To: <20121119.190753.856116050444408241.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 20/11/2012 01:07, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Fri, 16 Nov 2012 17:46:11 +0100
>
>> By default, the fb device is created, so there is no change if you
>> don't set explicitly setup_fb to 0.
>
>
> Nicolas, this idea is contentous to me too.
>
> Why not put this aside and submit the other parts of your
> patch set on their own, since those looked fine to me?
Ok, no problem. I wanted to get feedback about this kind of idea, I und=
erstand=20
the point.

When you said "the other parts", you mean only patch 2/4 (sit: allow to=
=20
configure 6rd tunnels via netlink) or 3/4 and 4/4 too?
Because 3/4 and 4/4 are equivalent to this one.
