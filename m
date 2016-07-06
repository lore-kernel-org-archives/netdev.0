From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH] net: tracepoint napi:napi_poll add work and
 budget
Date: Wed, 6 Jul 2016 09:19:12 +0200
Message-ID: <20160706091912.2e9cc431@redhat.com>
References: <20160705173444.3113.23769.stgit@firesoul>
	<20160705.115544.1669783693320652521.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rostedt@goodmis.org, brouer@redhat.com
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53806 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752525AbcGFHTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jul 2016 03:19:16 -0400
In-Reply-To: <20160705.115544.1669783693320652521.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Jul 2016 11:55:44 -0700 (PDT)
David Miller <davem@redhat.com> wrote:

> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Tue, 05 Jul 2016 19:35:27 +0200
> 
> > Can this patch go thought the net-next tree?  
> 
> Sure... when it actually compiles.
>
> If you're changing a fundamental signature like this, it is in your
> best interest to do an allmodconfig build... before I do.

Ups! sorry about that! I'll fix it up and resubmit.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
