From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next] m_bpf: add frontend support for late
 binding
Date: Mon, 10 Aug 2015 11:19:32 -0700
Message-ID: <20150810111932.40d21c8c@urahara>
References: <6a0435db24466adf0c0f85165e69e98a91183676.1438939738.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, jiri@resnulli.us, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34283 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932351AbbHJSTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2015 14:19:22 -0400
Received: by pawu10 with SMTP id u10so145467987paw.1
        for <netdev@vger.kernel.org>; Mon, 10 Aug 2015 11:19:22 -0700 (PDT)
In-Reply-To: <6a0435db24466adf0c0f85165e69e98a91183676.1438939738.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri,  7 Aug 2015 11:36:50 +0200
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Frontend support for kernel commit a5c90b29e5cc ("act_bpf: properly
> support late binding of bpf action to a classifier").
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied to net-next
