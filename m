From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH v1 net-next 0/6] Extend socket timestamping API
Date: Wed, 26 Apr 2017 18:54:35 +0200
Message-ID: <20170426165435.GA21114@localhost.localdomain>
References: <20170426145035.25846-1-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        "Keller, Jacob E" <jacob.e.keller@intel.com>,
        Denny Page <dennypage@me.com>, Jiri Benc <jbenc@redhat.com>
To: Miroslav Lichvar <mlichvar@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:35886 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752326AbdDZQyk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 12:54:40 -0400
Received: by mail-wr0-f170.google.com with SMTP id l50so3528850wrc.3
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 09:54:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170426145035.25846-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 26, 2017 at 04:50:29PM +0200, Miroslav Lichvar wrote:
> This patchset adds new options to the timestamping API that will be
> useful for NTP implementations and possibly other applications.

Are there any userland ntp patches floating around to exercise the new
HW time stamping option?

Thanks,
Richard
