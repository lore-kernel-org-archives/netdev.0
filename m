From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCHv2 2.6.24] fib: fix route replacement, fib_info is shared
Date: Mon, 28 Jan 2008 09:36:27 +0100
Message-ID: <20080128083627.GB2115@ff.dom.local>
References: <20080127232018.GA2856@ami.dom.local> <20080128083302.GA2115@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Joonwoo Park <joonwpark81@gmail.com>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:59997 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbYA1I3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 03:29:38 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1626033fga.17
        for <netdev@vger.kernel.org>; Mon, 28 Jan 2008 00:29:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080128083302.GA2115@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 28, 2008 at 09:33:02AM +0100, Jarek Poplawski wrote:
...
> from fib_node_alias() with right tos but greater fib_priority, but

"from fib_find_alias()" of course...

arek P. 
