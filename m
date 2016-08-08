From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/3] Few BPF helper related checksum fixes
Date: Mon, 08 Aug 2016 13:12:01 -0700 (PDT)
Message-ID: <20160808.131201.1253115691943227891.davem@davemloft.net>
References: <cover.1470346863.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32786 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbcHHUME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 16:12:04 -0400
Received: by mail-pf0-f194.google.com with SMTP id i6so25578922pfe.0
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 13:12:04 -0700 (PDT)
In-Reply-To: <cover.1470346863.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri,  5 Aug 2016 00:11:10 +0200

> The set contains three fixes with regards to CHECKSUM_COMPLETE
> and BPF helper functions. For details please see individual
> patches.
> 
> Thanks!
> 
> v1 -> v2:
>   - Fixed make htmldocs issue reported by kbuild bot.
>   - Rest as is.

Series applied, thanks!
