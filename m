From: "Nithin Sujir" <nsujir@broadcom.com>
Subject: RE: Latest 3.6.6 are not compiling due tg3 network driver,
 hwmon_device_unregister
Date: Thu, 15 Nov 2012 07:22:20 +0000
Message-ID: <DAAFBCC105999F468732FA900576CB4510069F69@IRVEXCHMB08.corp.ad.broadcom.com>
References: <8b566c4a9ee622737212dc17291ee238@visp.net.lb>
 <50A4606D.4020402@broadcom.com>
 <alpine.DEB.2.00.1211141929510.14414@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "Denys Fedoryshchenko" <denys@visp.net.lb>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "David Rientjes" <rientjes@google.com>,
	"Paul Gortmaker" <paul.gortmaker@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1211141929510.14414@chino.kir.corp.google.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Rientjes [mailto:rientjes@google.com]
> Sent: Wednesday, November 14, 2012 7:31 PM
> To: Nithin Sujir; Paul Gortmaker
> Cc: Denys Fedoryshchenko; Michael Chan; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org
> Subject: Re: Latest 3.6.6 are not compiling due tg3 network driver,
> hwmon_device_unregister
> 
> On Wed, 14 Nov 2012, Nithin Nayak Sujir wrote:
> 
> > This was fixed by
> >
> > commit de0a41484c47d783dd4d442914815076aa2caac2
> > Author: Paul Gortmaker <paul.gortmaker@windriver.com>
> > Date:   Mon Oct 1 11:43:49 2012 -0400
> >
> >     tg3: unconditionally select HWMON support when tg3 is enabled.
> >
> 
> Would you mind submitting this for stable by following the procedure
> described in Documentation/stable_kernel_rules.txt?


Seems to have been taken into stable already. 
http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=commitdiff;h=aecdc33e111b2c447b622e287c6003726daa1426

Nithin.
