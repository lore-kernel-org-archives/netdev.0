From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next v3 1/2] device property: Return -ENXIO if there
 is no suitable FW interface
Date: Thu, 27 Aug 2015 14:25:00 -0700 (PDT)
Message-ID: <20150827.142500.1481598801191967627.davem@davemloft.net>
References: <1440646025-18999-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, steve.glendinning@shawell.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rafael.j.wysocki@intel.com, jeremy.linton@arm.com, tony@atomide.com
To: linux@roeck-us.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440646025-18999-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guenter Roeck <linux@roeck-us.net>
Date: Wed, 26 Aug 2015 20:27:04 -0700

> Return -ENXIO if device property array access functions don't find
> a suitable firmware interface.
> 
> This lets drivers decide if they should use available platform data
> instead.
> 
> Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

Applied.
