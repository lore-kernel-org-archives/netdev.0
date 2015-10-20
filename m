From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv3 net 2/4] openvswitch: Clarify conntrack COMMIT behaviour
Date: Tue, 20 Oct 2015 14:53:52 -0700
Message-ID: <CALnjE+qGMAD6ishjg005q+mPSds3cf-McnVhTtoc8EPXDHzy0A@mail.gmail.com>
References: <1445307540-6786-1-git-send-email-joestringer@nicira.com>
	<1445307540-6786-2-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	Jarno Rajahalme <jrajahalme@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35302 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbbJTVxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 17:53:52 -0400
Received: by iofz202 with SMTP id z202so37836355iof.2
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 14:53:52 -0700 (PDT)
In-Reply-To: <1445307540-6786-2-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 19, 2015 at 7:18 PM, Joe Stringer <joestringer@nicira.com> wrote:
> The presence of this attribute does not modify the ct_state for the
> current packet, only future packets. Make this more clear in the header
> definition.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
