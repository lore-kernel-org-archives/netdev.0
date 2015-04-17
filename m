From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] ip: Add color output option
Date: Fri, 17 Apr 2015 09:44:03 -0700
Message-ID: <20150417164402.GA7041@Alexeis-MBP.westell.com>
References: <20150417130202.GA29596@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, aleksi.aalto@iki.fi
To: Mathias Nyman <m.nyman@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:34948 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436AbbDQQoF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2015 12:44:05 -0400
Received: by iejt8 with SMTP id t8so76591856iej.2
        for <netdev@vger.kernel.org>; Fri, 17 Apr 2015 09:44:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150417130202.GA29596@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 17, 2015 at 04:02:02PM +0300, Mathias Nyman wrote:
> It is hard to quickly find what you are looking for in the output of the ip
> command. Color helps.
> 
> This patch adds a '-c' flag to highlight these with individual colors:
>   - interface name
>   - ip addresse
>   - mac addresse
>   - up/down state

idea looks good, but the patch doesn't apply at all, since it's
whitespace damaged. Also there is no SOB.
