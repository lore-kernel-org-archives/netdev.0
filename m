From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH] net: Provide lwtstate_free for non-lwt config
Date: Wed, 19 Aug 2015 17:06:36 -0700
Message-ID: <CALCkm3dOiuH==vDN5YTA8o8yNUgq7Ldp-Zc5VxdS_MniL9LzUA@mail.gmail.com>
References: <1440022566-4081118-1-git-send-email-agartrell@fb.com>
 <CALCkm3fQCR7vTFUTX1n2rDED9Wkc_5_pKt7JiU35x7CdgQGCnQ@mail.gmail.com> <1440026904.6610.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Gartrell <agartrell@fb.com>,
	David Miller <davem@davemloft.net>, jbenc@redhat.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34016 "EHLO
	mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750767AbbHTAG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 20:06:56 -0400
Received: by qkfh127 with SMTP id h127so8686647qkf.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 17:06:56 -0700 (PDT)
In-Reply-To: <1440026904.6610.36.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 4:28 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> We've seen similar patches earlier today on netdev ;)

Ah, the mailing list equivalent of someone letting you know that you
left your fly down :)

Sorry for the noise!
