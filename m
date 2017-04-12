From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 0/5] netlink extended ACK reporting
Date: Wed, 12 Apr 2017 08:57:38 -0600
Message-ID: <24573d2e-abde-af5b-1b00-583dc687639e@cumulusnetworks.com>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Benc <jbenc@redhat.com>, jiri@resnulli.us
To: Johannes Berg <johannes@sipsolutions.net>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:35830 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752432AbdDLO5o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:57:44 -0400
Received: by mail-io0-f171.google.com with SMTP id r16so42614157ioi.2
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 07:57:43 -0700 (PDT)
In-Reply-To: <20170412123408.22012-1-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/12/17 6:34 AM, Johannes Berg wrote:
> Changes since v4:
>  * use __NLMSGERR_ATTR_MAX instead of NUM_NLMSGERR_ATTRS
> 

Dave uses the cover letter with the change history in the merge commit
logs. Would be good to keep the design intent and history.
