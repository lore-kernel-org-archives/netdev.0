From: Adam Jaremko <adam.jaremko@gmail.com>
Subject: Re: linux-next ftmac100 driver
Date: Tue, 26 Apr 2011 12:08:11 -0400
Message-ID: <BANLkTi=Eud9toM5HtHCSxNkPPrVEVgOCfg@mail.gmail.com>
References: <BANLkTin24N2D_b_RpPCQdjYn2f=C7NY2JA@mail.gmail.com>
	<D557AF68929979498EDCFCBB34FFD4E82C62BC@ftcpcs78.faraday.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: ratbert.chuang@gmail.com, netdev@vger.kernel.org
To: =?UTF-8?B?UmF0YmVydCBQby1ZdSBDaHVhbmco6I6K5Y2a5a6HKQ==?=
	<ratbert@faraday-tech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:40506 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754553Ab1DZQIN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 12:08:13 -0400
Received: by gxk21 with SMTP id 21so279301gxk.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 09:08:11 -0700 (PDT)
In-Reply-To: <D557AF68929979498EDCFCBB34FFD4E82C62BC@ftcpcs78.faraday.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You can try to use udelay() to replace usleep_range(). I will also check this problem when I am free later.
> If you solved this problem before me, please send a message (and keep the CC list).
> It will be even better if you could submit a patch. :-)

That is what I ended up doing and am able to continue with my testing.
