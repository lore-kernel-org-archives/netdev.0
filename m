From: Alex Gartrell <alexgartrell@gmail.com>
Subject: Re: [PATCH] net: Provide lwtstate_free for non-lwt config
Date: Wed, 19 Aug 2015 15:41:46 -0700
Message-ID: <CALCkm3fQCR7vTFUTX1n2rDED9Wkc_5_pKt7JiU35x7CdgQGCnQ@mail.gmail.com>
References: <1440022566-4081118-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, jbenc@redhat.com,
	roopa@cumulusnetworks.com, netdev <netdev@vger.kernel.org>
To: Alex Gartrell <agartrell@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:35124 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbbHSWmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 18:42:07 -0400
Received: by qkbm65 with SMTP id m65so8142918qkb.2
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 15:42:05 -0700 (PDT)
In-Reply-To: <1440022566-4081118-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 19, 2015 at 3:16 PM, Alex Gartrell <agartrell@fb.com> wrote:
> Fixes: df383e624 ("lwtunnel: fix memory leak")

Ah sorry, this is PATCH net-next, obviously :/
