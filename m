From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V4 net-next 05/26] bfin_mac: Support the get_ts_info
 ethtool method.
Date: Fri, 6 Apr 2012 09:04:06 +0200
Message-ID: <20120406070406.GB2220@netboy.at.omicron.at>
References: <cover.1333529504.git.richardcochran@gmail.com>
 <88e5b2cfcabda03826bb576b21e2e1d990f07117.1333529506.git.richardcochran@gmail.com>
 <CAP=VYLq1kCqLxi31HcGavKk8e3ydX43Xz-7rwayLJPWAnfk28Q@mail.gmail.com>
 <20120406.001805.562264431747635985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, mporter@solarflare.com,
	jacob.e.keller@intel.com, jeffrey.t.kirsher@intel.com,
	john.ronciak@intel.com, e1000-devel@lists.sourceforge.net,
	linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120406.001805.562264431747635985.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 06, 2012 at 12:18:05AM -0400, David Miller wrote:
> > Trailing semicolon.  Compile fail in linux-next due to a85bbddd.
> 
> I just pushed out the obvious fix for this.

Paul, thanks for compile testing, and David, thanks for fixing these.
Next time I promise to do at least the compile testing for the various
different architectures.

Richard
