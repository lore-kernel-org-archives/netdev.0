From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH v3] openvswitch: Add Kconfig dependency on GRE-DEMUX.
Date: Fri, 28 Jun 2013 18:22:38 -0700
Message-ID: <CAEP_g=_k9VCPwANhRc+T3xOboECVWZQs1SEtUaz0YfFtFiS71Q@mail.gmail.com>
References: <1372460860-19052-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:50066 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752927Ab3F2BW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 21:22:59 -0400
Received: by mail-ie0-f171.google.com with SMTP id qd12so5499839ieb.16
        for <netdev@vger.kernel.org>; Fri, 28 Jun 2013 18:22:58 -0700 (PDT)
In-Reply-To: <1372460860-19052-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 28, 2013 at 4:07 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Openvswitch uses function from NET_IPGRE_DEMUX module.
> Add Kconfig dependency to fix following compilation errors:
> http://marc.info/?l=linux-netdev&m=137244035226634
>
> CC: Jesse Gross <jesse@nicira.com>
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Signed-off-by: Pravin Shelar <pshelar@nicira.com>

Acked-by: Jesse Gross <jesse@nicira.com>
