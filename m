From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v4 net-next 5/8] geneve: Add support to collect tunnel metadata.
Date: Wed, 26 Aug 2015 19:10:53 -0700
Message-ID: <CAEP_g=8dNmHfYLXv-NeZs7hXtnF-Jv5r6q5bpuU-r+FF2UHKMA@mail.gmail.com>
References: <1440626079-11689-1-git-send-email-pshelar@nicira.com> <1440626079-11689-6-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:33064 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbH0CLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 22:11:14 -0400
Received: by labns7 with SMTP id ns7so3226894lab.0
        for <netdev@vger.kernel.org>; Wed, 26 Aug 2015 19:11:13 -0700 (PDT)
In-Reply-To: <1440626079-11689-6-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 26, 2015 at 2:54 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch create new tunnel flag which enable
> tunnel metadata collection on given device. These devices
> can be used by tunnel metadata based routing or by OVS.
> Geneve Consolidation patch get rid of collect_md_tun to
> simplify tunnel lookup further.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
