From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] iputils ping: add (non-raw) ICMP socket support
Date: Thu, 9 Apr 2015 08:49:39 +0900
Message-ID: <CAKD1Yr2FByA-NSrj=petsJPHbXz3dKApgjJ1p0mn_HeWh=89Mg@mail.gmail.com>
References: <2142872.6QHf5ZAfZz@msg-id> <5093199.DdecKAOFEl@msg-id>
 <5525198E.7030509@miraclelinux.com> <5635504.5jEhSFiGfj@msg-id>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segooon@gmail.com>,
	Tyler Hicks <tyhicks@canonical.com>
To: Salvatore Mesoraca <s.mesoraca16@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:32980 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890AbbDHXuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 19:50:00 -0400
Received: by iebmp1 with SMTP id mp1so88150103ieb.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 16:50:00 -0700 (PDT)
In-Reply-To: <5635504.5jEhSFiGfj@msg-id>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 8, 2015 at 10:05 PM, Salvatore Mesoraca
<s.mesoraca16@gmail.com> wrote:
>> And, would you provide patch for ping6 as well?
>
> I was planning to work on ping6 as well If this patch get accepted.

Yoshifuji-san,

I sent you a patch that works for both IPv4 and IPv6 a couple of years ago:

http://marc.info/?l=linux-netdev&m=137026384215378
http://marc.info/?l=linux-netdev&m=137026384815379

This code has been running on Android since then:

https://android-review.googlesource.com/#/c/61948/

Perhaps we can start from that patchset?

Cheers,
Lorenzo
