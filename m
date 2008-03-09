From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][AX25] ax25_out: check skb for NULL in ax25_kick()
Date: Sun, 9 Mar 2008 15:30:52 +0100
Message-ID: <20080309143052.GA2749@ami.dom.local>
References: <20080206074529.GC4496@ff.dom.local> <20080213115607.GB2867@ff.dom.local> <025801c86ea3$75add3f0$453c822c@dg8ngn> <47D3A7AF.1030607@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jann Traschewski <jann@gmx.de>,
	'David Miller' <davem@davemloft.net>,
	'Ralf Baechle' <ralf@linux-mips.org>, netdev@vger.kernel.org
To: Pidoux <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:60124 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485AbYCIO1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 10:27:21 -0400
Received: by nf-out-0910.google.com with SMTP id g13so565237nfb.21
        for <netdev@vger.kernel.org>; Sun, 09 Mar 2008 07:27:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47D3A7AF.1030607@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 09, 2008 at 10:02:39AM +0100, Pidoux wrote:
...
>>> Subject: [AX25] ax25_out: check skb for NULL in ax25_kick()
...
> Applied too and stable with kernel 2.6.24.3 since a week.

Good to know! It's merged to 2.6.25-rc3, but maybe recommending it for
2.6.24 wouldn't be a bad idea...

Thanks Bernard,
Jarek P.
