From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: Re: [PATCH 1/1] sfc: Staticize efx_ethtool_get_ts_info
Date: Wed, 11 Sep 2013 10:13:01 +0530
Message-ID: <CAK9yfHwgzv-S85o8FFau33h2_YwrWg_6ntdM533_9Px1NKxw5Q@mail.gmail.com>
References: <1378806210-12155-1-git-send-email-sachin.kamat@linaro.org>
	<1378814891.32513.29.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:60521 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755228Ab3IKEnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 00:43:02 -0400
Received: by mail-oa0-f54.google.com with SMTP id j10so8915759oah.13
        for <netdev@vger.kernel.org>; Tue, 10 Sep 2013 21:43:02 -0700 (PDT)
In-Reply-To: <1378814891.32513.29.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 September 2013 17:38, Ben Hutchings <bhutchings@solarflare.com> wrote:
> On Tue, 2013-09-10 at 15:13 +0530, Sachin Kamat wrote:
>> 'efx_ethtool_get_ts_info' is used only in this file.
>> Make it static.

>
> I already have this fix, but net-next is not open for changes.

I wasn't aware. Sorry for the noise.

-- 
With warm regards,
Sachin
