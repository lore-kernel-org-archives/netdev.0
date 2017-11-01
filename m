From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 3/3] xfrm_{state,policy}: Allow to deleteall
 polices/states with marks
Date: Wed, 1 Nov 2017 22:05:08 +0100
Message-ID: <20171101220508.5be2176f@shemminger-XPS-13-9360>
References: <97621e2c-30e3-aba3-ed5a-71241d94ec26@secunet.com>
        <20171031181359.5b868f1a@shemminger-XPS-13-9360>
        <d87947e6-39b4-cd5d-3ad7-b76da4eebd51@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Thomas Egerer <thomas.egerer@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:45090 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933124AbdKAVFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:05:34 -0400
Received: by mail-lf0-f65.google.com with SMTP id n69so4029893lfn.2
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 14:05:34 -0700 (PDT)
In-Reply-To: <d87947e6-39b4-cd5d-3ad7-b76da4eebd51@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 1 Nov 2017 10:52:54 +0100
Thomas Egerer <thomas.egerer@secunet.com> wrote:

> Using 'ip deleteall' with policies that have marks, fails unless you
> eplicitely specify the mark values. This is very uncomfortable when
> bulk-deleting policies and states. With this patch all relevant states
> and policies are wiped by 'ip deleteall' regardless of their mark
> values.
> 
> Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>

Like netdev to the kernel, you need to resend the whole patch series.
