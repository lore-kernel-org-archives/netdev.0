From: "Ertman, DavidX M" <davidx.m.ertman@intel.com>
Subject: RE: Request for stable inclusion
Date: Wed, 30 Apr 2014 19:40:03 +0000
Message-ID: <2B0E3F215D1AB84DA946C8BEE234CCC9370ECAF9@ORSMSX101.amr.corp.intel.com>
References: <alpine.DEB.2.02.1404302055200.6261@ionos.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thomas Gleixner <tglx@linutronix.de>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.02.1404302055200.6261@ionos.tec.linutronix.de>
Content-Language: en-US
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Thomas Gleixner [mailto:tglx@linutronix.de]
> Sent: Wednesday, April 30, 2014 12:04 PM
> To: stable@vger.kernel.org
> Cc: Kirsher, Jeffrey T; Ertman, DavidX M; netdev@vger.kernel.org
> Subject: Request for stable inclusion
> 
> Hi,
> 
> commit b20a774495671f037e7160ea2ce8789af6b61533
> Author: David Ertman <davidx.m.ertman@intel.com>
> Date:   Tue Mar 25 04:27:55 2014 +0000
> 
>     e1000e: Fix no connectivity when driver loaded with cable out
> 
> fixes an issue which affects quite some of the newer Laptops and also
> Desktops (e.g. AOI-PCs) which are based on mobile chipsets.
> 
> I don't know how far this reaches back, but at least the 3.13 and 3.14
> kernels need this fix. Jeff, David, can you tell?
> 
> Please consider for inclusion.
> 
> Thanks,
> 
> 	tglx

The commit that caused the issue went into net-next on June 21, 2013.  So at least 3.11 and forward, and probably 3.10.

Dave Ertman
