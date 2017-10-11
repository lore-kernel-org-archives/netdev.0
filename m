From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] tests: Remove bashisms (s/source/.)
Date: Wed, 11 Oct 2017 11:01:15 -0700
Message-ID: <20171011110115.13739488@xeon-e3>
References: <20171008143916.21813-1-petr.vorel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Petr Vorel <petr.vorel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:45656 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752405AbdJKSBW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 14:01:22 -0400
Received: by mail-pg0-f49.google.com with SMTP id b192so1410651pga.2
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 11:01:22 -0700 (PDT)
In-Reply-To: <20171008143916.21813-1-petr.vorel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun,  8 Oct 2017 16:39:16 +0200
Petr Vorel <petr.vorel@gmail.com> wrote:

> Signed-off-by: Petr Vorel <petr.vorel@gmail.com>

Ok, applied. But iproute2 is really limited to Linux and bash is lingua franca on Linux
