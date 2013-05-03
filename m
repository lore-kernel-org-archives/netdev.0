From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net/usb: new driver for RTL8152
Date: Fri, 03 May 2013 00:00:52 -0400 (EDT)
Message-ID: <20130503.000052.680733925880090504.davem@davemloft.net>
References: <20130503023328.GB26712@kroah.com>
	<4215C45C849149B8A86B57F8D603AAEA@realtek.com.tw>
	<20130503032315.GA22077@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hayeswang@realtek.com, oliver@neukum.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	nic_swsd@realtek.com
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130503032315.GA22077@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: 'Greg KH' <gregkh@linuxfoundation.org>
Date: Thu, 2 May 2013 20:23:15 -0700

> On Fri, May 03, 2013 at 11:11:47AM +0800, hayeswang wrote:
>> Greg KH [mailto:gregkh@linuxfoundation.org] 
>> > Sent: Friday, May 03, 2013 10:33 AM
>> > To: Hayeswang
>> > Cc: oliver@neukum.org; netdev@vger.kernel.org; 
>> > linux-kernel@vger.kernel.org; linux-usb@vger.kernel.org; nic_swsd
>> > Subject: Re: [PATCH v3 net-next] net/usb: new driver for RTL8152
>> > 
>> > On Fri, May 03, 2013 at 10:01:25AM +0800, Hayes Wang wrote:
>> > > Add new driver for supporting Realtek RTL8152 Based USB 2.0 
>> > Ethernet Adapters
>> > > 
>> > > Signed-off-by: Hayes Wang <hayeswang@realtek.com>
>> > > Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
>> > 
>> > You removed the wording I had questions about last time, does 
>> > that mean
>> > the previous wording was not correct, or that you no longer are
>> > publicising the fact that this driver reads on some patents that you
>> > own?
>> > 
>> > You also failed to answer my previous questions, why?
>> 
>> That description is about the patent for the hw design, not for
>> software. It indicates that the design of the hw uses those patents
>> from the other compnay. I have no idea about how to deal with those
>> patents. What should I do for sending a patch? 
> 
> That makes sense to me, removing it is correct.  It's now up to the
> netdev developers to accept this, thanks for the quick response.

I think this clears things up and that specific issue is no longer a
blocker for inclusion.

I'll let this sit on the list so that it may be reviewed on it's
technical merits.
