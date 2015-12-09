From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next] ipv6: allow routes to be configured with expire values
Date: Wed, 9 Dec 2015 19:50:38 +0800
Message-ID: <CADvbK_eXZZ+owgQy8+V71gW1Y_sDwnPNsz_eVgXpHiekhCvsoQ@mail.gmail.com>
References: <b813d147f9f4c938fbe4c3e0e671e88b2afcf412.1449585464.git.lucien.xin@gmail.com>
	<20151208.225620.67864748611461829.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Miller <davem@davemloft.net>, jk@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36643 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbLILui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 06:50:38 -0500
Received: by igcph11 with SMTP id ph11so116603671igc.1
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 03:50:38 -0800 (PST)
In-Reply-To: <20151208.225620.67864748611461829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2015 at 11:56 AM, David Miller <davem@davemloft.net> wrote:
> From: Xin Long <lucien.xin@gmail.com>
> Date: Tue,  8 Dec 2015 22:37:44 +0800
>
>> Add the support for adding expire value to routes,  requested by
>> Tom Gundersen <teg@jklm.no> for systemd-networkd, and NetworkManager
>> wants it too.
>>
>> add it by using the field rta_expires of rta_cacheinfo
>>
>> Signed-off-by: Xin Long <lucien.xin@gmail.com>
>> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>
> Fix your outgoing patch emails, the From: field doesn't have your
> full name in it so the commit AUTHOR fields look terrible.

it's not the from field issue, it's the incorrect  full name of my account in
patchwork, I have send mail to Jeremy Kerr to help correct it.

after he do it, i will report, thanks.
