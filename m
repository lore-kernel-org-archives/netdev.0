From: Ralf Baechle <ralf@linux-mips.org>
Subject: Re: [PATCH v2 0/5] MIPS: BPF: JIT fixes and improvements.
Date: Wed, 15 Mar 2017 14:08:23 +0100
Message-ID: <20170315130823.GA5512@linux-mips.org>
References: <20170314212144.29988-1-david.daney@cavium.com>
 <20170314.172937.1289357366273291363.davem@davemloft.net>
 <1d09f001-aa15-e3bf-be85-a13b1132a12a@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, david.daney@cavium.com,
        linux-mips@linux-mips.org, james.hogan@imgtec.com, ast@kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        steven.hill@cavium.com
To: David Daney <ddaney@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eddie.linux-mips.org ([148.251.95.138]:45718 "EHLO
        cvs.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753358AbdCOP2A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 11:28:00 -0400
Received: from localhost.localdomain ([127.0.0.1]:39218 "EHLO linux-mips.org"
        rhost-flags-OK-OK-OK-FAIL) by eddie.linux-mips.org with ESMTP
        id S23991232AbdCOP161FIyV (ORCPT <rfc822;netdev@vger.kernel.org>
        + 1 other); Wed, 15 Mar 2017 16:27:58 +0100
Content-Disposition: inline
In-Reply-To: <1d09f001-aa15-e3bf-be85-a13b1132a12a@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 14, 2017 at 05:34:02PM -0700, David Daney wrote:

> > What tree are you targetting with these changes?  Do you expect
> > them to go via the MIPS or the net-next tree?
> > 
> > Please be explicit about this in the future.
> > 
> 
> Sorry I didn't mention it.
> 
> My expectation is that Ralf would merge it via the MIPS tree, as it is fully
> contained within arch/mips/*

Thanks, applied.

  Ralf
