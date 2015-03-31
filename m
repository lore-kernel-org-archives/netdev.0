From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 00/23] ptp: get ready for 2038
Date: Tue, 31 Mar 2015 12:01:45 -0400 (EDT)
Message-ID: <20150331.120145.1205079649994752161.davem@davemloft.net>
References: <cover.1427662906.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	amirv@mellanox.com, ariel.elior@qlogic.com, arnd@linaro.org,
	baolin.wang@linaro.org, ben@decadent.org.uk,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	cmetcalf@ezchip.com, Frank.Li@freescale.com,
	peppe.cavallaro@st.com, jacob.e.keller@intel.com,
	jeffrey.t.kirsher@intel.com, john.stultz@linaro.org,
	b45643@freescale.com, matthew.vick@intel.com, mchan@broadcom.com,
	prashant@broadcom.com, rayagond@vayavyalabs.com,
	sshah@solarflare.com, linux-net-drivers@solarflare.com,
	sonic.zhang@analog.com, stefan.sorensen@spectralink.com,
	tglx@linutronix.de, thomas.lendacky@amd.com
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1427662906.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Sun, 29 Mar 2015 23:11:50 +0200

> This series converts the core driver methods of the PTP Hardware Clock
> (PHC) subsystem to use the 64 bit version of the timespec structure,
> making the core API ready for the year 2038.

Looks great, series applied, thanks Richard.
