From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v4 net-next 0/7] Extend socket timestamping API
Date: Thu, 18 May 2017 15:20:04 +0200
Message-ID: <20170518132004.GA24687@localhost>
References: <20170518130656.24163-1-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36284 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934008AbdERNUH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 09:20:07 -0400
Content-Disposition: inline
In-Reply-To: <20170518130656.24163-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 18, 2017 at 02:58:23PM +0200, Miroslav Lichvar wrote:
> Changes v3->v4:
> - added reserved fields to struct scm_ts_pktinfo

Of course, I forgot to initialize the new reserved fields. I'll send a
new series.

-- 
Miroslav Lichvar
