From: Deepak Vishwakarma <vishwakarma.deepak@gmail.com>
Subject: Re: PF_RING for n/w traffic more than 1 Gbps
Date: Mon, 22 Jun 2009 18:42:56 +0530
Message-ID: <e31d15d70906220612p7a27deb3y949c6693f1b5646a@mail.gmail.com>
References: <e31d15d70906220020y70f0daf9k4650d96c402fdf7a@mail.gmail.com>
	 <20090622.002834.240476749.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f197.google.com ([209.85.222.197]:62737 "EHLO
	mail-pz0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756580AbZFVNMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 09:12:53 -0400
Received: by pzk35 with SMTP id 35so733350pzk.33
        for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 06:12:56 -0700 (PDT)
In-Reply-To: <20090622.002834.240476749.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks,

Regards,
Deepak K. Vishwakarma

On Mon, Jun 22, 2009 at 12:58 PM, David Miller<davem@davemloft.net> wrote:
> From: Deepak Vishwakarma <vishwakarma.deepak@gmail.com>
> Date: Mon, 22 Jun 2009 12:50:11 +0530
>
>> PF_RING kernel patch not optimized for traffic handling more than 1
>> Gbps. I am facing packet overrun over 1 Gbps with linux 2.6.30 patched
>> with PF_RING.
>>
>> Does any one has achieved more than 2-3 Gbps packet handling with or
>> without PF_RING.
>
> You'll have more luck with this question on the networking developer
> list, netdev@vger.kernel.org, which has been CC:'d
>



-- 
Deepak Kumar Vishwakarma
Scientist, DRDO
