From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] remove open coded ns_to_timespec64 and
 reverse
Date: Tue, 31 Mar 2015 17:19:36 -0400 (EDT)
Message-ID: <20150331.171936.517523024908985101.davem@davemloft.net>
References: <cover.1427835485.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	amirv@mellanox.com, arnd@linaro.org, baolin.wang@linaro.org,
	Frank.Li@freescale.com, peppe.cavallaro@st.com,
	jacob.e.keller@intel.com, jeffrey.t.kirsher@intel.com,
	john.stultz@linaro.org, b45643@freescale.com,
	matthew.vick@intel.com, mchan@broadcom.com, prashant@broadcom.com,
	rayagond@vayavyalabs.com, sonic.zhang@analog.com,
	sony.chacko@qlogic.com, tglx@linutronix.de
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427835485.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Tue, 31 Mar 2015 23:08:05 +0200

> This patch series is a follow up to the recent timespec64 work for the
> PTP Hardware Clock drivers.  Arnd noticed that drivers are using open
> coded implementations of ns_to_timespec64 and timespec64_to_ns.  This
> series replaces the open coded logic with the helper functions.

Looks good, series applied, thanks.
