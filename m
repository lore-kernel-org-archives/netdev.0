From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v5 1/2] flow dissector: ICMP support
Date: Wed, 7 Dec 2016 13:26:29 +0100
Message-ID: <20161207122629.GE1987@nanopsycho>
References: <1481112880-9801-1-git-send-email-simon.horman@netronome.com>
 <1481112880-9801-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f194.google.com ([209.85.210.194]:33997 "EHLO
        mail-wj0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbcLGM0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 07:26:32 -0500
Received: by mail-wj0-f194.google.com with SMTP id xy5so49538013wjc.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 04:26:31 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481112880-9801-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 07, 2016 at 01:14:39PM CET, simon.horman@netronome.com wrote:
>Allow dissection of ICMP(V6) type and code. This should only occur
>if a packet is ICMP(V6) and the dissector has FLOW_DISSECTOR_KEY_ICMP set.
>
>There are currently no users of FLOW_DISSECTOR_KEY_ICMP.
>A follow-up patch will allow FLOW_DISSECTOR_KEY_ICMP to be used by
>the flower classifier.


You are missing signedoff line.
