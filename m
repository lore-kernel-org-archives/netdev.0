From: Mourad De Clerck <mourad@aquazul.com>
Subject: Re: [RFT] Realtek 8168 ethernet support
Date: Mon, 12 Jun 2006 12:30:14 +0200
Message-ID: <448D4236.9050505@aquazul.com>
References: <20060601200200.A0E0689D05D@zog.reactivated.net> <20060608143133.7e36a0b7.rdunlap@xenotime.net> <4488DF85.3090901@garzik.org> <20060609183358.GA5835@electric-eye.fr.zoreil.com> <4489C290.6020705@garzik.org> <20060610120523.GA24288@electric-eye.fr.zoreil.com> <20060610224811.GA3256@electric-eye.fr.zoreil.com> <20060611233022.GA11776@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.ypu.org ([80.242.208.21]:33414 "EHLO heaven.risen.be")
	by vger.kernel.org with ESMTP id S1751815AbWFLKaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 06:30:21 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060611233022.GA11776@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/06/06 01:30, Francois Romieu wrote:
> The patch below agaisnt 2.6.17-rc6 includes the following changes:

Just FYI:

I just tried this patch set, but it doesn't do anything for the "freeze
at high speed" I mentioned on 2006-06-09. It still locks up. (As an
additional data point: I installed win2k on this machine, and it seems
to have no problems transferring at high speeds. Just wanted to try to
rule out faulty hardware.)

Thanks,

-- Mourad DC
