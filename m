From: Kamal Mostafa <kamal@canonical.com>
Subject: Re: [PATCH][v3.13.y] e1000e: Fix no connectivity when driver loaded
 with cable out
Date: Tue, 13 Jan 2015 10:29:09 -0800
Message-ID: <1421173749.6540.1.camel@fourier>
References: <5491B88E.3070906@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Kamal Mostafa <kamal.mostafa@canonical.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	davidx.m.ertman@intel.com, jeffrey.e.pieper@intel.com,
	jeffrey.t.kirsher@intel.com, LKML <linux-kernel@vger.kernel.org>,
	linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Joseph Salisbury <joseph.salisbury@canonical.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5491B88E.3070906@canonical.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-12-17 at 12:08 -0500, Joseph Salisbury wrote:
> Hello,
> 
> Please consider including mainline commit b20a774 in the next v3.13.y
> stable release.  It was included in the mainline tree as of v3.15-rc1. 
> It has been tested and confirmed to resolve
> http://bugs.launchpad.net/bugs/1400365 .
> 
> commit b20a774495671f037e7160ea2ce8789af6b61533
> Author: David Ertman <davidx.m.ertman@intel.com>
> Date:   Tue Mar 25 04:27:55 2014 +0000
> 
>     e1000e: Fix no connectivity when driver loaded with cable out

Yes, I'll queue this up for the next 3.13-stable.  Thanks, Joseph!

 -Kamal
