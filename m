From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 00/11] remove open coded ns_to_timespec64 and
 reverse
Date: Tue, 31 Mar 2015 23:38:53 +0200
Message-ID: <20150331213852.GB9139@localhost.localdomain>
References: <cover.1427835485.git.richardcochran@gmail.com>
 <1427836290.16312.29.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"baolin.wang@linaro.org" <baolin.wang@linaro.org>,
	"b45643@freescale.com" <b45643@freescale.com>,
	"amirv@mellanox.com" <amirv@mellanox.com>,
	"peppe.cavallaro@st.com" <peppe.cavallaro@st.com>,
	"sonic.zhang@analog.com" <sonic.zhang@analog.com>,
	"rayagond@vayavyalabs.com" <rayagond@vayavyalabs.com>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"sony.chacko@qlogic.com" <sony.chacko@qlogic.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"arnd@linaro.org" <arnd@linaro.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"prashant@broadcom.com" <prashant@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427836290.16312.29.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 31, 2015 at 09:11:30PM +0000, Keller, Jacob E wrote:
> For all the Intel drivers, this looks fine. I'm surprised I never
> noticed before.

I think the helpers appeared only after the first PHC drivers.

Thanks,
Richard
