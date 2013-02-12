From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v5 08/11] act_police: move struct tcf_police to
 act_police.c
Date: Tue, 12 Feb 2013 08:34:35 -0800
Message-ID: <1360686875.6884.2.camel@edumazet-glaptop>
References: <1360663929-1023-1-git-send-email-jiri@resnulli.us>
	 <1360663929-1023-9-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:37207 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933439Ab3BLQej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 11:34:39 -0500
Received: by mail-da0-f45.google.com with SMTP id w4so97903dam.18
        for <netdev@vger.kernel.org>; Tue, 12 Feb 2013 08:34:39 -0800 (PST)
In-Reply-To: <1360663929-1023-9-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-12 at 11:12 +0100, Jiri Pirko wrote:
> It's not used anywhere else, so move it.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
