From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [V2 PATCH net-next 0/5] xdp: more work on xdp tracepoints
Date: Wed, 23 Aug 2017 13:16:42 +0200
Message-ID: <20170823131642.3f0b5ca2@redhat.com>
References: <599D42B8.6040200@iogearbox.net>
        <150348327373.23476.14851572406177222309.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>, brouer@redhat.com
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55770 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753691AbdHWLQr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Aug 2017 07:16:47 -0400
In-Reply-To: <150348327373.23476.14851572406177222309.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Aug 2017 12:15:14 +0200
Jesper Dangaard Brouer <brouer@redhat.com> wrote:

> More work on streamlining the tracepoints for XDP.
> 
> V2: Change trace_xdp_redirect() to align with args of trace_xdp_exception()

Heads-up DaveM, just rebased my tree and noticed a merge conflict on
net-next... I'll send a V3

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
