From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: updates to syncookies - timestamps not needed any more (freebsd)
Date: Fri, 12 Jul 2013 10:00:19 -0700
Message-ID: <1373648419.10804.32.camel@edumazet-glaptop>
References: <20130708160421.GA9763@order.stressinduktion.org>
	 <20130711.165726.2168148122875413191.davem@davemloft.net>
	 <20130712014138.GD12611@order.stressinduktion.org>
	 <CAFLxGvzihGSgNZ5NOJxMN2pgQiCPXgJSRjVCcj3Ncfw3oe_YLA@mail.gmail.com>
	 <51E01F2A.3030602@hp.com> <1373645937.10804.19.camel@edumazet-glaptop>
	 <51E02FF7.3070608@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: richard -rw- weinberger <richard.weinberger@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:48645 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965035Ab3GLRAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 13:00:21 -0400
Received: by mail-pa0-f52.google.com with SMTP id kq13so9072610pab.39
        for <netdev@vger.kernel.org>; Fri, 12 Jul 2013 10:00:21 -0700 (PDT)
In-Reply-To: <51E02FF7.3070608@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-12 at 09:33 -0700, Rick Jones wrote:

> Tsk, tsk, tsk...  or am I believing too strongly in the importance of 
> protection against wrapped sequence numbers?


Presumably Microsoft do not expect their machines being able to transfer
TCP at high speed...
