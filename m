From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH/RFC net-next] rocker: remove rocker parameter from
 functions that have rocker_port parameter
Date: Wed, 27 May 2015 22:11:16 -0700
Message-ID: <CAE4R7bBgVMHiM4wCGb+YvM8i1jbds1W03OfzbtTxMVOzBg_bVg@mail.gmail.com>
References: <1432783397-12868-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, Netdev <netdev@vger.kernel.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:33858 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbbE1FLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 01:11:17 -0400
Received: by qkoo18 with SMTP id o18so18803485qko.1
        for <netdev@vger.kernel.org>; Wed, 27 May 2015 22:11:16 -0700 (PDT)
In-Reply-To: <1432783397-12868-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 27, 2015 at 8:23 PM, Simon Horman
<simon.horman@netronome.com> wrote:
> The rocker (switch) of a rocker_port may be trivially obtained from
> the latter it seems cleaner not to pass the former to a function when
> the latter is being passed anyway.
>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

+1, thanks Simon.

Acked-by: Scott Feldman <sfeldma@gmail.com>
