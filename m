From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] Time Counter fixes and improvements
Date: Tue, 30 Dec 2014 18:32:01 -0500 (EST)
Message-ID: <20141230.183201.53211717284248412.davem@davemloft.net>
References: <cover.1418504883.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	amirv@mellanox.com, ariel.elior@qlogic.com,
	carolyn.wyborny@intel.com, Frank.Li@freescale.com,
	jeffrey.t.kirsher@intel.com, john.stultz@linaro.org,
	matthew.vick@intel.com, mlichvar@redhat.com, mugunthanvnm@ti.com,
	ogerlitz@mellanox.com, tglx@linutronix.de, thomas.lendacky@amd.com
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1418504883.git.richardcochran@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Richard Cochran <richardcochran@gmail.com>
Date: Sun, 21 Dec 2014 19:46:55 +0100

> Several PTP Hardware Clock (PHC) drivers implement the clock in
> software using the timecounter/cyclecounter code. This series adds on=
e
> simple improvement and one more subtle fix to the shared timecounter
> facility. Credit for this series goes to Janusz U=BFycki, who pointed
> the issues out to me off list.

Series applied, thanks Richard.
