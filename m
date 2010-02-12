From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: [PATCH 1/2] e1000e: Only disable ASPM on 82573L devices
Date: Fri, 12 Feb 2010 12:54:23 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1002121249480.5328@jbrandeb-desk1.amr.corp.intel.com>
References: <1265756630-8093-1-git-send-email-mjg@redhat.com> <20100212.123917.109973609.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "mjg@redhat.com" <mjg@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	bruce.w.allan@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100212.123917.109973609.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 12 Feb 2010, David Miller wrote:
> Intel folks, are you looking at these patches?

Hi Dave, yes we're looking at them but due to Bruce being out, we need to 
wait until next week to reply.  If you can wait, we'll make sure they come 
through Jeff or receive comments after full review.

It's a bit of a scary area to mess with as there were lots of ASPM related 
bugs in the hardware in this hardware generation (system chipsets and 
82573).
