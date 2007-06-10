From: "David Planella" <david.planella@googlemail.com>
Subject: Re: The future of the TI ACX wireless driver
Date: Sun, 10 Jun 2007 19:27:21 +0200
Message-ID: <1d9d9b240706101027m7e6aef2er25474fd6e9459e9e@mail.gmail.com>
References: <1d9d9b240706100735k374b5800ie64370e1e9bff1ef@mail.gmail.com>
	 <466C2F94.8050501@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: acx100-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: "linux-wireless@hauke-m.de" <linux-wireless@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:50482 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755380AbXFJR1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2007 13:27:22 -0400
Received: by an-out-0708.google.com with SMTP id d31so335951and
        for <netdev@vger.kernel.org>; Sun, 10 Jun 2007 10:27:21 -0700 (PDT)
In-Reply-To: <466C2F94.8050501@hauke-m.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hauke,

Thanks for your reply. See the inline comments:

2007/6/10, linux-wireless@hauke-m.de <linux-wireless@hauke-m.de>:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> Hi
>
> Nice work David.
>
> I have extracted the acxsm driver out of the wireless-2.6 git tree and
> made it compile on at least kernel 2.6.20 and 2.6.22-rc4
> It can be found here:
> http://www.hauke-m.de/fileadmin/acx/tiacx-20070522.tar.bz2
>

I do not think more effort should be put in the softmac version, but
rather concentrate on the mac80211 version. I'm having a look at the
patch Jeff Williams sent earlier on today, but as I said, cannot
promise anything.

> I also chanced some lines in the normal acx driver so it compiles with
> kenrel 2.6.22 and later
> http://www.hauke-m.de/fileadmin/acx/acx-20070610.tar.bz2
>

you might want to send a patch to acx100-devel or to Andreas Mohr for that.

> I will write some pages into the Wiki for these versions, so everyone
> can test them.
>

Yes, that would be good. A page with instructions on how to compile
the latest acx-mac80211 would even be better.

Regards,
David.
