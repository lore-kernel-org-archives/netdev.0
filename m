From: "Grant Likely" <grant.likely@secretlab.ca>
Subject: Re: netif_schedule and mpc5200_fec
Date: Wed, 23 Jul 2008 00:57:20 -0400
Message-ID: <fa686aa40807222157u437641efud22d5fa8546a6025@mail.gmail.com>
References: <9e4733910807221554j451019a0sa711541e97fbf0aa@mail.gmail.com>
	 <20080722.160718.122532549.davem@davemloft.net>
	 <9e4733910807221633x4385c36dod81ac3f81e242e5c@mail.gmail.com>
	 <20080722.163626.109432106.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jonsmirl@gmail.com, davem@redhat.com, Linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.244]:20766 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbYGWE5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 00:57:21 -0400
Received: by ag-out-0708.google.com with SMTP id 31so14335651agc.10
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 21:57:20 -0700 (PDT)
In-Reply-To: <20080722.163626.109432106.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 22, 2008 at 7:36 PM, David Miller <davem@davemloft.net> wrote:
> From: "Jon Smirl" <jonsmirl@gmail.com>
>> You're right. That patch fixes it. Another thing I brought down made
>> my image file not get generated and I was using an old image.
>
> Thanks for confirming this Jon.

Thanks for fixing it!

Cheers,
g.

-- 
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
