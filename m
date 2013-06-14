From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 1/4] openvswitch: Unify vport error stats handling.
Date: Fri, 14 Jun 2013 07:41:00 -0700
Message-ID: <CAEP_g=8ZPprZUxhPBhwgec5ENCLozDCZaQjYX4tU8Pekue_rpw@mail.gmail.com>
References: <1371147086-29178-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog104.obsmtp.com ([74.125.149.73]:44343 "HELO
	na3sys009aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751363Ab3FNOlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jun 2013 10:41:22 -0400
Received: by mail-ie0-f179.google.com with SMTP id c10so1605143ieb.38
        for <netdev@vger.kernel.org>; Fri, 14 Jun 2013 07:41:20 -0700 (PDT)
In-Reply-To: <1371147086-29178-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 13, 2013 at 11:11 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch changes vport->send return type so that vport
> layer can do error accounting.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Already applied.
