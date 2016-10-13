From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH iproute2] tc: cls_bpf: handle skip_sw and skip_hw flags
Date: Thu, 13 Oct 2016 11:06:57 +0200
Message-ID: <20161013090657.GH18804@verge.net.au>
References: <1476287196-28931-1-git-send-email-jakub.kicinski@netronome.com>
 <57FE5EC7.3010405@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43897 "EHLO
        kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752193AbcJMJHl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 05:07:41 -0400
Content-Disposition: inline
In-Reply-To: <57FE5EC7.3010405@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2016 at 06:03:19PM +0200, Daniel Borkmann wrote:
> On 10/12/2016 05:46 PM, Jakub Kicinski wrote:
> >Add support for controling hardware offload using (now standard)
> >skip_sw and skip_hw flags in cls_bpf.
> >
> >Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
