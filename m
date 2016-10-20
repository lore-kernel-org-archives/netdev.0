From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 3/4] ptp_clock: allow for it to be optional
Date: Thu, 20 Oct 2016 11:50:12 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1610201149190.5073@nanos>
References: <1476920573-14384-1-git-send-email-nicolas.pitre@linaro.org> <1476920573-14384-4-git-send-email-nicolas.pitre@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: John Stultz <john.stultz@linaro.org>,
        Richard Cochran <richardcochran@gmail.com>,
        Yann E MORIN <yann.morin.1998@free.fr>,
        Josh Triplett <josh@joshtriplett.org>, netdev@vger.kernel.org,
        linux-kbuild@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <1476920573-14384-4-git-send-email-nicolas.pitre@linaro.org>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 19 Oct 2016, Nicolas Pitre wrote:
> The pch_gbe driver is a bit special as it relies on extra code in
> drivers/ptp/ptp_pch.c. Therefore we let the make process descend into
> drivers/ptp/ even if PTP_1588_CLOCK is unselected.

The above paragraph looks like a leftover of the previous patch set.
 
Thanks,

	tglx
