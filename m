From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Provide lwtstate_free for non-lwt config
Date: Wed, 19 Aug 2015 16:28:24 -0700
Message-ID: <1440026904.6610.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440022566-4081118-1-git-send-email-agartrell@fb.com>
	 <CALCkm3fQCR7vTFUTX1n2rDED9Wkc_5_pKt7JiU35x7CdgQGCnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alex Gartrell <agartrell@fb.com>,
	David Miller <davem@davemloft.net>, jbenc@redhat.com,
	roopa@cumulusnetworks.com, netdev <netdev@vger.kernel.org>
To: Alex Gartrell <alexgartrell@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34406 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751058AbbHSX20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 19:28:26 -0400
Received: by paccq16 with SMTP id cq16so13162715pac.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 16:28:26 -0700 (PDT)
In-Reply-To: <CALCkm3fQCR7vTFUTX1n2rDED9Wkc_5_pKt7JiU35x7CdgQGCnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-19 at 15:41 -0700, Alex Gartrell wrote:
> On Wed, Aug 19, 2015 at 3:16 PM, Alex Gartrell <agartrell@fb.com> wrote:
> > Fixes: df383e624 ("lwtunnel: fix memory leak")
> 
> Ah sorry, this is PATCH net-next, obviously :/


We've seen similar patches earlier today on netdev ;)
