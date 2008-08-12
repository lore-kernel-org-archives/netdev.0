From: "Parag Warudkar" <parag.warudkar@gmail.com>
Subject: Re: [Bugme-new] [Bug 11297] New: OOPS in rt6_fill_node
Date: Mon, 11 Aug 2008 20:01:57 -0400
Message-ID: <82e4877d0808111701k8cf8b5p60623a65eb6bda95@mail.gmail.com>
References: <20080809213101.0927a808.akpm@linux-foundation.org>
	 <489F8827.4030904@hp.com>
	 <82e4877d0808101805t55a6ec5ft6c9b171ac1c7c3ab@mail.gmail.com>
	 <20080811.143212.172434871.davem@davemloft.net>
	 <48A0CEEA.9080104@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.224]:18000 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913AbYHLAB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 20:01:58 -0400
Received: by wx-out-0506.google.com with SMTP id h29so1421739wxd.4
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 17:01:57 -0700 (PDT)
In-Reply-To: <48A0CEEA.9080104@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 11, 2008 at 7:44 PM, Brian Haley <brian.haley@hp.com> wrote:

> I don't see "EOF on netlink" on 2.6.27-rc2.  I can dig-up a 2.6.24 kernel,
> I'm just wondering if that EOF happens when the IPv6 module isn't loaded or
> something?

With ipv6 not loaded it returns not supported or something similar -
correct of course.

What output do you see with your patch?

Parag
