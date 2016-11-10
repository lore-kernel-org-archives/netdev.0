From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] PHC frequency fine tuning
Date: Wed, 09 Nov 2016 21:20:25 -0500 (EST)
Message-ID: <20161109.212025.33151158831725274.davem@davemloft.net>
References: <cover.1478526333.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jacob.e.keller@intel.com,
        jeffrey.t.kirsher@intel.com, john.stultz@linaro.org,
        Manfred.Rudigier@omicron.at, stefan.sorensen@spectralink.com,
        tglx@linutronix.de, ulrik.debie-os@e2big.org,
        intel-wired-lan@lists.osuosl.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47680 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754668AbcKJCU3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 21:20:29 -0500
In-Reply-To: <cover.1478526333.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue,  8 Nov 2016 22:49:15 +0100

> This series expands the PTP Hardware Clock subsystem by adding a
> method that passes the frequency tuning word to the the drivers
> without dropping the low order bits.  Keeping those bits is useful for
> drivers whose frequency resolution is higher than 1 ppb.

Series applied, thanks Richard.
