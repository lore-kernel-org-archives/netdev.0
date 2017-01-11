From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/2] flow disector: ARP support
Date: Wed, 11 Jan 2017 14:26:58 +0100
Message-ID: <20170111132658.GI1852@nanopsycho>
References: <1484139943-18199-1-git-send-email-simon.horman@netronome.com>
 <1484139943-18199-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Jiri Pirko <jiri@mellanox.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f195.google.com ([209.85.210.195]:35042 "EHLO
        mail-wj0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966554AbdAKN1B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 08:27:01 -0500
Received: by mail-wj0-f195.google.com with SMTP id ey1so11734097wjd.2
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 05:27:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484139943-18199-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jan 11, 2017 at 02:05:42PM CET, simon.horman@netronome.com wrote:
>Allow dissection of (R)ARP operation hardware and protocol addresses
>for Ethernet hardware and IPv4 protocol addresses.
>
>There are currently no users of FLOW_DISSECTOR_KEY_ARP.
>A follow-up patch will allow FLOW_DISSECTOR_KEY_ARP to be used by the
>flower classifier.
>
>Signed-off-by: Simon Horman <simon.horman@netronome.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
