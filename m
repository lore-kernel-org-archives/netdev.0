From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/4] PTP attribute handling cleanup
Date: Fri, 17 Feb 2017 11:03:31 -0500 (EST)
Message-ID: <20170217.110331.1583774566670151929.davem@davemloft.net>
References: <20170214182334.23296-1-dmitry.torokhov@gmail.com>
        <20170216201928.GA8614@netboy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry.torokhov@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170216201928.GA8614@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Richard Cochran <richardcochran@gmail.com>
Date: Thu, 16 Feb 2017 21:19:29 +0100

> On Tue, Feb 14, 2017 at 10:23:30AM -0800, Dmitry Torokhov wrote:
>>  drivers/ptp/ptp_clock.c   |  22 +++---
>>  drivers/ptp/ptp_private.h |   7 +-
>>  drivers/ptp/ptp_sysfs.c   | 167 ++++++++++++++++++----------------------------
>>  3 files changed, 80 insertions(+), 116 deletions(-)
> 
> Nice reduction in sysfs code!
> 
> I gave this some light testing on the coldfire/phyter (which has 12
> pins), and nothing exploded.
> 
> For the series:
> 
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Series applied to net-next, thanks.
