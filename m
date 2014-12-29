From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH] net: flow: Guard against accessing non-existent attributes
Date: Mon, 29 Dec 2014 09:53:30 -0800
Message-ID: <54A1951A.2070209@gmail.com>
References: <1419819455-19109-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35068 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbaL2Rxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 12:53:44 -0500
Received: by mail-oi0-f50.google.com with SMTP id x69so29848196oia.9
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 09:53:43 -0800 (PST)
In-Reply-To: <1419819455-19109-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/28/2014 06:17 PM, Simon Horman wrote:
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> ---
>   net/core/flow_table.c | 11 +++++++++++
>   1 file changed, 11 insertions(+)

Great thanks. I rolled it into the patches I should hopefully have
ready to submit later today.

By the way I got this working on rocker now so we can test it easier,
I'll post the driver updates as well.

.John

-- 
John Fastabend         Intel Corporation
