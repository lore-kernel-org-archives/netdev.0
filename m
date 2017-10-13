From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH] nfp: Explicitly include linux/bug.h
Date: Thu, 12 Oct 2017 20:16:43 -0700
Message-ID: <20171012201643.08ff9f4f@cakuba.netronome.com>
References: <20171013025035.4450-1-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Simon Horman <simon.horman@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org
To: Mark Brown <broonie@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:44309 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753305AbdJMDQv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 23:16:51 -0400
Received: by mail-qt0-f178.google.com with SMTP id 8so17327845qtv.1
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 20:16:51 -0700 (PDT)
In-Reply-To: <20171013025035.4450-1-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Oct 2017 03:50:35 +0100, Mark Brown wrote:
> Today's -next build encountered an error due to a missing definition of
> WARN_ON(), caused by some header reorganization removing an implicit
> inclusion of linux/bug.h.  Fix this with an explicit inclusion.
> 
> Signed-off-by: Mark Brown <broonie@kernel.org>

Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Thank you!
