From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net 1/2] net: stmmac: add platform init/exit for Altera's
 ARM socfpga
Date: Sat, 28 Jun 2014 10:40:42 -0500
Message-ID: <CAOwfj2NBpJN71UTEnQcZspA4CRVneJaBVW0Fu0VhkLNz+duUMA@mail.gmail.com>
References: <1403483701-21199-1-git-send-email-vbridgers2013@gmail.com>
	<1403483701-21199-2-git-send-email-vbridgers2013@gmail.com>
	<20140625.155918.1075841150895163513.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:46131 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbaF1Pkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 11:40:43 -0400
Received: by mail-we0-f177.google.com with SMTP id u56so6279838wes.8
        for <netdev@vger.kernel.org>; Sat, 28 Jun 2014 08:40:42 -0700 (PDT)
In-Reply-To: <20140625.155918.1075841150895163513.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 25, 2014 at 5:59 PM, David Miller <davem@davemloft.net> wrote:
> From: Vince Bridgers <vbridgers2013@gmail.com>
> Date: Sun, 22 Jun 2014 19:35:00 -0500
>
>> +     return ret;
>> +}
>>  const struct stmmac_of_data socfpga_gmac_data = {
>
> Please always place one empty line between top-level declarations.

Thanks, I'll address and respin the patch
