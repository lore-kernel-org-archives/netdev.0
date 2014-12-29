From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] net: flow: Allow actions and matches to be NULL in net_flow_put_flow()
Date: Mon, 29 Dec 2014 09:56:23 -0800
Message-ID: <54A195C7.3010009@gmail.com>
References: <1419819602-23290-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:53137 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751522AbaL2R4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 12:56:34 -0500
Received: by mail-oi0-f54.google.com with SMTP id u20so29768213oif.13
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 09:56:34 -0800 (PST)
In-Reply-To: <1419819602-23290-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/28/2014 06:20 PM, Simon Horman wrote:
> This makes the handing of the absence of actions or matches
> symmetric with net_flow_get_flow().
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---

Again thanks I actually just hit this with my rocker implementation
so very timely fix. Same story here I'll roll it into the patch and
submit it later today.

.John

-- 
John Fastabend         Intel Corporation
