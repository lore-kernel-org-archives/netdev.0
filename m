From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] net/pch_gbe: supports eg20t ptp clock
Date: Tue, 6 Mar 2012 10:25:43 +0100
Message-ID: <20120306092542.GA28585@localhost.localdomain>
References: <1330926377-11531-1-git-send-email-tshimizu818@gmail.com>
 <20120305.005709.1597475617000728984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tshimizu818@gmail.com, jeffrey.t.kirsher@intel.com,
	lucas.demarchi@profusion.mobi, mirq-linux@rere.qmqm.pl,
	paul.gortmaker@windriver.com, toshiharu-linux@dsn.okisemi.com,
	jdmason@kudzu.us, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qi.wang@intel.com,
	yong.y.wang@intel.com, joel.clark@intel.com, kok.howg.ewe@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120305.005709.1597475617000728984.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2012 at 12:57:09AM -0500, David Miller wrote:
> 
> So how the heck is this supposed to work?
> 
> You post a patch for the e20tp clock source, you don't CC: netdev.
> 
> Then you post this network driver patch which depends upon that on
> and you do CC: netdev.
> 
> You've made it impossible for me to apply them both properly into my
> tree so that the dependency goes in.

I'm confused. Are you talking about a patch from last August?

In any case, if there two patches, then they should of course appear
together.

Thanks,
Richard
