From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 8/9] geneve: Move device hash table to geneve socket.
Date: Wed, 19 Aug 2015 12:05:10 -0700
Message-ID: <CAEP_g=9YtQyCdsNqB=ULGcLuH_Sr_skx7e4QeSzOAA+ZkVeB5w@mail.gmail.com>
References: <1439845905-31666-1-git-send-email-pshelar@nicira.com> <1439845905-31666-9-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:32780 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbbHSTFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 15:05:32 -0400
Received: by lbbsx3 with SMTP id sx3so9589486lbb.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 12:05:31 -0700 (PDT)
In-Reply-To: <1439845905-31666-9-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 17, 2015 at 2:11 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> This change simplifies Geneve Tunnel hash table management.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
