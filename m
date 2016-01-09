From: Jesse Gross <jesse@kernel.org>
Subject: Re: [PATCH net-next v4 08/10] geneve: break dependency to network drivers
Date: Sat, 9 Jan 2016 13:59:54 -0800
Message-ID: <CAEh+42ghSNGgK9-W1x8DZkSmGugLMu2AGu0p2J3c2VTp0+DXjA@mail.gmail.com>
References: <1452352052-27574-1-git-send-email-hannes@stressinduktion.org> <1452352052-27574-9-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:50942 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756051AbcAIWAL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 17:00:11 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 76704202B8
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 22:00:10 +0000 (UTC)
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B3541202AE
	for <netdev@vger.kernel.org>; Sat,  9 Jan 2016 22:00:09 +0000 (UTC)
Received: by mail-qg0-f44.google.com with SMTP id b35so248104797qge.0
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 14:00:09 -0800 (PST)
In-Reply-To: <1452352052-27574-9-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 9, 2016 at 7:07 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  drivers/net/geneve.c | 37 ++++++++++++++++++++++++++++++-------
>  include/net/geneve.h |  7 +++----
>  2 files changed, 33 insertions(+), 11 deletions(-)

Reviewed-by: Jesse Gross <jesse@kernel.org>

Thanks!
