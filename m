From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] tc: make tc linking depend on libtc.a
Date: Mon, 9 Jan 2017 12:08:00 -0800
Message-ID: <20170109120800.71c968ee@xeon-e3>
References: <87wpebu3c1.fsf@coreos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Michael <david.michael@coreos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:35319 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751143AbdAIUII (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:08:08 -0500
Received: by mail-pf0-f173.google.com with SMTP id f144so23503764pfa.2
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 12:08:08 -0800 (PST)
In-Reply-To: <87wpebu3c1.fsf@coreos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 03 Jan 2017 15:32:46 -0800
David Michael <david.michael@coreos.com> wrote:

> There was a race condition where the command to link the tc binary
> could (rarely) run before the libtc.a archive existed.

Applied, thanks.
I guess I need a 64 CPU machine.
