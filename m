From: "Grandhi, Sainath" <sainath.grandhi@intel.com>
Subject: RE: [PATCHv6 0/7] Refactor macvtap to re-use tap functionality by
 other virtual intefaces
Date: Mon, 13 Feb 2017 23:41:03 +0000
Message-ID: <2C5142675EC1274EAB6230F72F8DC95F414F150D@ORSMSX116.amr.corp.intel.com>
References: <1486771432-15085-1-git-send-email-sainath.grandhi@intel.com>
 <20170211.210020.1702909319217444459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mahesh@bandewar.net" <mahesh@bandewar.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170211.210020.1702909319217444459.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, February 11, 2017 6:00 PM
> To: Grandhi, Sainath <sainath.grandhi@intel.com>
> Cc: netdev@vger.kernel.org; mahesh@bandewar.net; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCHv6 0/7] Refactor macvtap to re-use tap functionality by
> other virtual intefaces
> 
> From: Sainath Grandhi <sainath.grandhi@intel.com>
> Date: Fri, 10 Feb 2017 16:03:45 -0800
> 
> > Tap character devices can be implemented on other virtual interfaces
> > like ipvlan, similar to macvtap. Source code for tap functionality in
> > macvtap can be re-used for this purpose.
> >
> > This patch series splits macvtap source into two modules, macvtap and tap.
> > This patch series also includes a patch for implementing tap character
> > device driver based on the IP-VLAN network interface, called ipvtap.
> >
> > These patches are tested on x86 platform.
> 
> Series applied, thanks.
Thanks David. 
May I know an approximate timeline, when your branch would be merged into linux?
