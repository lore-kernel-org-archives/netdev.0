From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 27 May 2005 20:56:26 -0400
Message-ID: <1117241786.6251.7.camel@localhost.localdomain>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
	 <20050527085055.79da3d75@dxpl.pdx.osdl.net>
	 <Pine.CYG.4.58.0505271305590.2148@mawilli1-desk2.amr.corp.intel.com>
	 <20050527140132.1435132d@dxpl.pdx.osdl.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mitch Williams <mitch.a.williams@intel.com>, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se, "Ronciak, John" <john.ronciak@intel.com>,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050527140132.1435132d@dxpl.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-27-05 at 14:01 -0700, Stephen Hemminger wrote:

> 
> Why not just allow adjusting dev->weight via sysfs?

I think that should be good enough - and i thought your patch already
did this. 
Adding a shift to the weight in a _weighted_ RR algorithm does sound
odd.

cheers,
jamal
