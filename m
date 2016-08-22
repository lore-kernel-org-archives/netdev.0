From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: fix build with musl libc
Date: Mon, 22 Aug 2016 10:02:38 -0700
Message-ID: <20160822100238.0ab543ac@xeon-e3>
References: <1471662670-20969-1-git-send-email-gustavo@zacarias.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Gustavo Zacarias <gustavo@zacarias.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36213 "EHLO
        mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752585AbcHVRCb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 13:02:31 -0400
Received: by mail-pa0-f53.google.com with SMTP id pp5so39281738pac.3
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 10:02:31 -0700 (PDT)
In-Reply-To: <1471662670-20969-1-git-send-email-gustavo@zacarias.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Aug 2016 00:11:10 -0300
Gustavo Zacarias <gustavo@zacarias.com.ar> wrote:

> UINT_MAX usage requires limits.h, so include it.
> 
> Signed-off-by: Gustavo Zacarias <gustavo@zacarias.com.ar>

Applied
