From: David Miller <davem@davemloft.net>
Subject: Re: [V2 PATCH net-next 0/5] xdp: more work on xdp tracepoints
Date: Wed, 23 Aug 2017 17:07:37 -0700 (PDT)
Message-ID: <20170823.170737.931093928208799430.davem@davemloft.net>
References: <599D42B8.6040200@iogearbox.net>
        <150348327373.23476.14851572406177222309.stgit@firesoul>
        <20170823131642.3f0b5ca2@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, borkmann@iogearbox.net
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53770 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751019AbdHXAHj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 20:07:39 -0400
In-Reply-To: <20170823131642.3f0b5ca2@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Wed, 23 Aug 2017 13:16:42 +0200

> On Wed, 23 Aug 2017 12:15:14 +0200
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
>> More work on streamlining the tracepoints for XDP.
>> 
>> V2: Change trace_xdp_redirect() to align with args of trace_xdp_exception()
> 
> Heads-up DaveM, just rebased my tree and noticed a merge conflict on
> net-next... I'll send a V3

Ok :)
