From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bc47xx : export ssb_watchdog_timer_set
Date: Tue, 19 May 2009 15:24:20 +0200
Message-ID: <200905191524.20421.mb@bu3sch.de>
References: <4A11DCBF.9000700@free.fr> <20090518224128.GA11912@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: matthieu castet <castet.matthieu@free.fr>,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20090518224128.GA11912@tuxdriver.com>
Content-Disposition: inline
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Tuesday 19 May 2009 00:41:28 John W. Linville wrote:
> On Tue, May 19, 2009 at 12:10:07AM +0200, matthieu castet wrote:
> > Hi,
> >
> > this patch export ssb_watchdog_timer_set to allow to use it in a Linux  
> > watchdog driver.
> >
> >
> > Signed-off-by: Matthieu CASTET <castet.matthieu@free.fr>
> 
> What is the merge path for ssb nowadays?  I used to take these patches
> (and I'm still happy to do so), but maybe Ralf is (or should be)
> taking them now?

That depends on his speed. Last time I submitted a patch through his path,
it bitrotted for several months before it finally hit mainline.

-- 
Greetings, Michael.
