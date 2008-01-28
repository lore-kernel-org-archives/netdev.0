From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv2 2.6.24] fib: fix route replacement, fib_info is shared
Date: Mon, 28 Jan 2008 09:56:11 +0100
Message-ID: <20080128085611.GA2362@ff.dom.local>
References: <20080127232018.GA2856@ami.dom.local> <20080128083302.GA2115@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Joonwoo Park <joonwpark81@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:9259 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760197AbYA1ItY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 03:49:24 -0500
Received: by ug-out-1314.google.com with SMTP id z38so958896ugc.16
        for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 00:49:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080128083302.GA2115@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 28, 2008 at 09:33:02AM +0100, Jarek Poplawski wrote:
...
> [...] Are these aliases in the node sorted by
> fib_priority too? [...] 

OK, I see they are!

Sorry for bothering,
Jarek P. 
