From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 1/4] openvswitch: Unify vport error stats handling.
Date: Wed, 12 Jun 2013 19:28:34 -0700
Message-ID: <CAEP_g=_vVbsYVR_7H5g1_mpecY58=-mO46ksEkmWR-f39kVTGg@mail.gmail.com>
References: <1371077819-19679-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:54457 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932071Ab3FMC2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 22:28:54 -0400
Received: by mail-ie0-f169.google.com with SMTP id 10so11682245ied.0
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 19:28:54 -0700 (PDT)
In-Reply-To: <1371077819-19679-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 12, 2013 at 3:56 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch changes vport->send return type so that vport
> layer can do error accounting.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

There's already a version of this patch in my tree on kernel.org.
