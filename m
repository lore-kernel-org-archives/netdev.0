From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH v4 0/2] bridge: fdb dumping takes a filter device
Date: Thu, 03 Jul 2014 05:35:31 -0400
Message-ID: <53B523E3.8030301@mojatatu.com>
References: <1403952456-16020-1-git-send-email-jhs@emojatatu.com>	<20140702.174114.1070001183436341599.davem@davemloft.net> <20140702.181958.175884390637356702.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-7; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	vyasevic@redhat.com, sfeldma@cumulusnetworks.com,
	john.r.fastabend@intel.com, roopa@cumulusnetworks.com,
	eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:53487 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030567AbaGCJfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 05:35:44 -0400
Received: by mail-ie0-f170.google.com with SMTP id tr6so10676015ieb.1
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 02:35:43 -0700 (PDT)
In-Reply-To: <20140702.181958.175884390637356702.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/02/14 21:19, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 02 Jul 2014 17:41:14 -0700 (PDT)
>
>> Series applied, thanks Jamal.
>
> Actually, I had to revert, this breaks the qlcnic build:
>

Apologies - I should have compiled that driver.
I fixed and tested and will be sending shortly.

cheers,
jamal
