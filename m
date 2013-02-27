From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute 2/2] ss: show socket memory stats for unix
 sockets if requested
Date: Tue, 26 Feb 2013 17:38:02 -0800
Message-ID: <20130226173802.73ca5c06@nehalam.linuxnetplumber.net>
References: <20130223012818.GA6655@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:40056 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755909Ab3B0Bi3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 20:38:29 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so83673pad.23
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 17:38:29 -0800 (PST)
In-Reply-To: <20130223012818.GA6655@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 23 Feb 2013 02:28:18 +0100
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> The output format is the same as for tcp sockets but only the following
> fields are currently non-zero: sk_rcvbuf, sk_wmem_alloc and sk_sndbuf.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Both applied
