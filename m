From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 3/4] ptp: use is_visible method to hide unused attributes
Date: Tue, 14 Feb 2017 19:13:27 +0100
Message-ID: <20170214181327.GB25995@localhost.localdomain>
References: <20170214035108.19622-1-dmitry.torokhov@gmail.com>
 <20170214035108.19622-3-dmitry.torokhov@gmail.com>
 <20170214084226.GC8048@localhost.localdomain>
 <20170214180747.GA4081@dtor-ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170214180747.GA4081@dtor-ws>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 14, 2017 at 10:07:47AM -0800, Dmitry Torokhov wrote:
> > At first glance, this patch and the next look like nice improvements.
> > I don't futz around with sysfs code very often, and so may I ask how
> > or whether you tested it?
> 
> I used the hack below.

OK, thats fine.  I'll be sure and test this here with my i210 which
has real pins.

Thanks,
Richard
