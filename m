From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: Re: [PATCH][XFRM_TUNNEL]: Reload header pointer after pskb_may_pull/pskb_expand_head
Date: Sun, 25 Feb 2007 00:31:38 -0200
Message-ID: <39e6f6c70702241831uf918dafm7254a05ad6ffd273@mail.gmail.com>
References: <39e6f6c70702241747l19dd1b21l9a28f7d6f64a4a6f@mail.gmail.com>
	 <39e6f6c70702241749l4c7128afyeed881245c2e3ac2@mail.gmail.com>
	 <20070224.181346.07640056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:25820 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933636AbXBYCbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Feb 2007 21:31:39 -0500
Received: by wx-out-0506.google.com with SMTP id h31so940162wxd
        for <netdev@vger.kernel.org>; Sat, 24 Feb 2007 18:31:39 -0800 (PST)
In-Reply-To: <20070224.181346.07640056.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/25/07, David Miller <davem@davemloft.net> wrote:
> From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
> Date: Sat, 24 Feb 2007 23:49:50 -0200
>
> > Oops, now with the patch.
>
> Thanks, applied.
>
> I'll queue this one up for -stable too.

Thanks!

- Arnaldo
