From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 16% regression on 10G caused by TCP small queues
Date: Wed, 23 Oct 2013 23:19:08 -0700
Message-ID: <1382595548.7572.39.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131023192954.3dd9c784@nehalam.linuxnetplumber.net>
	 <CADVnQymDr2K7z3yfKpW-H3R3W3NP+iuPQF2eMfeyS6dn-szdgA@mail.gmail.com>
	 <CAOaVG15indAxBz7E-T+9MK03indiXBa0UhQZ5j6K5DxYP44Mxg@mail.gmail.com>
	 <20131023.233816.1396918839771657154.davem@davemloft.net>
	 <20131023214557.386aad1a@nehalam.linuxnetplumber.net>
	 <1382595011.7572.36.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ncardwell@google.com,
	dave.taht@bufferbloat.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:58394 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752036Ab3JXGTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 02:19:13 -0400
Received: by mail-ee0-f48.google.com with SMTP id e50so847620eek.21
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 23:19:11 -0700 (PDT)
In-Reply-To: <1382595011.7572.36.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-23 at 23:10 -0700, Eric Dumazet wrote:

> Btw what is the NIC you are using ?

Oh well I read you mail and saw ixgbe was mentioned ;)
