From: Tomas Winkler <tomasw@gmail.com>
Subject: Re: [PATCH 1/3] iwmc3200top: Add Intel Wireless MultiCom 3200 top
	driver.
Date: Sun, 11 Oct 2009 15:07:03 +0200
Message-ID: <1ba2fa240910110607p3a6809f8k1e35ca08c425f1b9@mail.gmail.com>
References: <1ba2fa240910100238s709c31d3s6cb612f502b1086f@mail.gmail.com>
	 <20091010.185852.133969433.davem@davemloft.net>
	 <1ba2fa240910110105x33fb251ar3437dd5fee552735@mail.gmail.com>
	 <20091011.033647.66923614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-mmc@vger.kernel.org,
	yi.zhu@intel.com, inaky.perez-gonzalez@intel.com,
	cindy.h.kao@intel.com, guy.cohen@intel.com,
	ron.rindjunsky@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f210.google.com ([209.85.218.210]:64537 "EHLO
	mail-bw0-f210.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754598AbZJKNHl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2009 09:07:41 -0400
In-Reply-To: <20091011.033647.66923614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 11, 2009 at 12:36 PM, David Miller <davem@davemloft.net> wr=
ote:
> From: Tomas Winkler <tomasw@gmail.com>
> Date: Sun, 11 Oct 2009 10:05:20 +0200
>
>> Just close my eyes and there is new game to play. :)
>> It's not in the patchwork, so is there any reason you are not planni=
ng
>> to add it. =C2=A0 The patch intention was for net-next, it looks lik=
e
>> I didn't mark it as such, my fault.
>
> Because there still seems to be some confusion between which of these
> bits go through John Linville as a wireless driver and which bits
> go directly through me.
>
> By default I assume John picks up "wireless" drivers and send them
> to me in his wireless merges to me.
>
> If that's not the case, explicitly do a fresh submission of this patc=
h
> and explicitly ask me to merge it.

Thanks, got it know.
Since this goes for wimax and wifi I'd like to submit it directly to ne=
tdev.
I will resolve Marcel's comments and  submit again.
Thanks
Tomas
