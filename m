From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ptp: mark filter as __initdata
Date: Tue, 13 May 2014 13:17:39 -0400 (EDT)
Message-ID: <20140513.131739.2150354952382884301.davem@davemloft.net>
References: <1399753408-14861-1-git-send-email-minipli@googlemail.com>
	<CAADnVQJo-P7FTXUNXN58Dt0LK12pLjK04O7aq7LB1c-WPPdh_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: minipli@googlemail.com, netdev@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbaEMRRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:17:40 -0400
In-Reply-To: <CAADnVQJo-P7FTXUNXN58Dt0LK12pLjK04O7aq7LB1c-WPPdh_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Sat, 10 May 2014 15:22:38 -0700

> On Sat, May 10, 2014 at 1:23 PM, Mathias Krause <minipli@googlemail.com> wrote:
>> sk_unattached_filter_create() will copy the filter's instructions so we
>> don't need to have the master copy hanging around after initialization.
>>
>> Signed-off-by: Mathias Krause <minipli@googlemail.com>
> 
> Nice! Every bit counts.
> 
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks everyone.
