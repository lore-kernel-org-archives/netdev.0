From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: [PATCH] Documentation: document the gianfar tx vlan offload issue
Date: Fri, 4 Apr 2014 15:39:42 +0800
Message-ID: <CAJFZqHx9q8EfaVE-JrXmhJBM8R_t4y_0XwO596-fD9ObvsoW=g@mail.gmail.com>
References: <1396580685-17156-1-git-send-email-roy.qing.li@gmail.com>
	<533E5A19.6060701@freescale.com>
	<533E5B03.2050801@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Yanjun.Zhu@windriver.com
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:51879 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbaDDHjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 03:39:43 -0400
Received: by mail-qg0-f42.google.com with SMTP id q107so3032827qgd.1
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 00:39:42 -0700 (PDT)
In-Reply-To: <533E5B03.2050801@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> I don't really like this, this is hardly a technical explanation.
>> ("insane packets"?)
>> Please have a look at the HW reference manual.  There you have the
>> description
>> of the VLAN extraction feature (see VLEX).
>>
> And VLAN insertion (VLINS) as well, for that matter.
>
>

Not all users will have time to read HW reference manual, if we can give them
more explanation, I think it maybe save their time to debug, to see code, and
search manual

-Roy
