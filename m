From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RFC 0/12] Remove UDP Fragmentation Offload support
Date: Wed, 5 Jul 2017 08:52:17 -0700
Message-ID: <20170705085217.7161b3cb@xeon-e3>
References: <20170705.160402.80726683432003025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35806 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751681AbdGEPw2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:52:28 -0400
Received: by mail-pf0-f172.google.com with SMTP id c73so131715406pfk.2
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 08:52:28 -0700 (PDT)
In-Reply-To: <20170705.160402.80726683432003025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 05 Jul 2017 16:04:02 +0100 (WEST)
David Miller <davem@davemloft.net> wrote:

> This is an RFC patch series, based upon some discussions with
> various developers, that removes UFO offloading.
> 
> Very few devices support this operation, it's usefullness is
> quesitonable at best, and it adds a non-trivial amount of
> complexity to our data paths.
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>


Agreed, makes sense to me.
