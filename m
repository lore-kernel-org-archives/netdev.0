From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2-next] ss: output dctcp diag information
Date: Wed, 29 Oct 2014 22:53:22 -0700
Message-ID: <20141029225322.41baf3a7@urahara>
References: <1411980452-4669-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:37151 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756650AbaJ3Fxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 01:53:34 -0400
Received: by mail-pa0-f46.google.com with SMTP id lf10so4722433pab.19
        for <netdev@vger.kernel.org>; Wed, 29 Oct 2014 22:53:33 -0700 (PDT)
In-Reply-To: <1411980452-4669-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Sep 2014 10:47:32 +0200
Daniel Borkmann <dborkman@redhat.com> wrote:

> Dump useful DCTCP state/debug information gathered from diag.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, I had already got the header files from regular kernel headers update.
