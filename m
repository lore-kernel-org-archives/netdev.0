From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 00/11] Time Counter fixes and improvements
Date: Fri, 2 Jan 2015 19:49:56 +0100
Message-ID: <20150102184956.GA4206@localhost.localdomain>
References: <cover.1418504883.git.richardcochran@gmail.com>
 <CALAqxLUVU3XmBMiNGH-X5KjGbEjDYtaR2WRXDOHfGNads9caOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	David Miller <davem@davemloft.net>,
	Frank Li <Frank.Li@freescale.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Miroslav Lichvar <mlichvar@redhat.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Tom Lendacky <thomas.lendacky@amd.com>
To: John Stultz <john.stultz@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CALAqxLUVU3XmBMiNGH-X5KjGbEjDYtaR2WRXDOHfGNads9caOw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 02, 2015 at 10:37:09AM -0800, John Stultz wrote:
> Though, this does start to sound like issues the timekeeping code had
> to resolve, so while its probably time to let some flowers bloom and
> see what happens, we should be somewhat watchful for too much logic
> duplication.

You took the words right out of my mouth.

My feeling is that this timecounter code might become more
complicated, and if the core time keeping becomes more
straightforward, then maybe one day the two will join.

Thanks,
Richard
