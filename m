From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 08/24] net, diet: Make TCP metrics optional
Date: Wed, 7 May 2014 08:39:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F70DE29@AcuExch.aculab.com>
References: <20140506032114.GP2382@two.firstfloor.org>
 <20140505.232327.578134514220748085.davem@davemloft.net>
 <20140506155703.GA20391@cloud>
 <20140506.115941.428706504757835279.davem@davemloft.net>
 <20140506164108.GA20536@cloud>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "andi@firstfloor.org" <andi@firstfloor.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"tom.zanussi@linux.intel.com" <tom.zanussi@linux.intel.com>,
	"ak@linux.intel.com" <ak@linux.intel.com>
To: "'josh@joshtriplett.org'" <josh@joshtriplett.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140506164108.GA20536@cloud>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: josh@joshtriplett.org
...
> Every KB of RAM costs real money and SoC die area (for eDRAM/eSRAM).
> Look at how much cache low-end processors have, and imagine running
> entirely out of *that*.  Let's not surrender that entire class of
> devices to VxWorks, FreeRTOS, and other painfully non-Linux systems,
> when we already know it's possible to run Linux on them successfully.

Have you considered running (say) NetBSD instead of Linux?
You'll get more support there for running on 'small memory' systems.
You can also make your own changes with having issues with the GPL.

	David
