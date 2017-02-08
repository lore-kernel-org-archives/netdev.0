From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next repost] tc: flower: Update
 documentation to indicate ARP takes IPv4 prefixes
Date: Wed, 8 Feb 2017 11:39:59 -0800
Message-ID: <20170208113959.0df80a36@xeon-e3>
References: <1486555264-18257-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33496 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751007AbdBHTkf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:40:35 -0500
Received: by mail-io0-f178.google.com with SMTP id v96so124800869ioi.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 11:40:07 -0800 (PST)
In-Reply-To: <1486555264-18257-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  8 Feb 2017 13:01:04 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Unlike other PREFIXes documented in the usage for tc flower, which accept
> both IPv4 and IPv6 prefixes, arp_sip and arp_tip only accepts IPv4
> prefixes.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
>
Applied to net-next
