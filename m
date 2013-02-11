From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [flow_cache_new_hashrnd] WARNING: at kernel/smp.c:328
 smp_call_function_single()
Date: Mon, 11 Feb 2013 17:10:46 +0800
Message-ID: <20130211091046.GA12094@localhost>
References: <20130211085600.GB10857@localhost>
 <20130211090309.GA23932@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuansheng Liu <chuansheng.liu@intel.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Steven Rostedt <rostedt@goodmis.org>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130211090309.GA23932@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 11, 2013 at 10:03:09AM +0100, Ingo Molnar wrote:
> 
> * Fengguang Wu <fengguang.wu@intel.com> wrote:
> 
> > Greetings,
> > 
> > I got the below oops and the first bad commit is
> 
> It's a one-time warning, not an actual crash, right?

Yes, it is.

Thanks,
Fengguang
