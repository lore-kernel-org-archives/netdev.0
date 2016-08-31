From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC 1/9] ipv6: implement dataplane support for rthdr type 4
 (Segment Routing Header)
Date: Wed, 31 Aug 2016 10:13:44 -0700
Message-ID: <20160831101344.6a6a10fb@xeon-e3>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
        <1472226767-9904-2-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34491 "EHLO
        mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964930AbcHaRNg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2016 13:13:36 -0400
Received: by mail-pa0-f50.google.com with SMTP id fi15so20470856pac.1
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 10:13:35 -0700 (PDT)
In-Reply-To: <1472226767-9904-2-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Aug 2016 17:52:39 +0200
David Lebrun <david.lebrun@uclouvain.be> wrote:

> +
> +	/* cleanup */
> +
> +	if (cleanup) {

Unnecessary comment, you aren't saying anything with this.
