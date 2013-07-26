From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 2/2] lnstat: Fix compiler errors of unused
 return-values
Date: Fri, 26 Jul 2013 14:29:02 -0700
Message-ID: <20130726142902.53c229b4@nehalam.linuxnetplumber.net>
References: <1374513857-6096-1-git-send-email-christoph.paasch@uclouvain.be>
	<1374513857-6096-3-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Paasch <christoph.paasch@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:37289 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933477Ab3GZV3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 17:29:06 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp13so2462300pab.21
        for <netdev@vger.kernel.org>; Fri, 26 Jul 2013 14:29:05 -0700 (PDT)
In-Reply-To: <1374513857-6096-3-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 22 Jul 2013 19:24:17 +0200
Christoph Paasch <christoph.paasch@uclouvain.be> wrote:

> Many errors when compiling with gcc 4.7.3 about unused return-values
> upon the calls to fgets:

Nak, I just took of Werror instead.
