From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2] ip: add fastopen_no_cookie option to ip
 route
Date: Wed, 1 Nov 2017 22:08:46 +0100
Message-ID: <20171101220846.37237854@shemminger-XPS-13-9360>
References: <20171031215452.7580-1-cpaasch@apple.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Paasch <cpaasch@apple.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:52045 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933270AbdKAVJN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 17:09:13 -0400
Received: by mail-lf0-f65.google.com with SMTP id r129so4015888lff.8
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 14:09:13 -0700 (PDT)
In-Reply-To: <20171031215452.7580-1-cpaasch@apple.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 31 Oct 2017 14:54:52 -0700
Christoph Paasch <cpaasch@apple.com> wrote:

> This patch adds fastopen_no_cookie option to enable/disable TCP fastopen
> without a cookie on a per-route basis.
> 
> Support in Linux was added with 71c02379c762 (tcp: Configure TFO without
> cookie per socket and/or per route).
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Christoph Paasch <cpaasch@apple.com>

Applied to net-next branch of iproute2.
