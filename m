From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] abysmal e1000 performance (DITR)
Date: 26 Aug 2004 13:55:30 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093542930.1027.124.camel@jzny.localdomain>
References: <468F3FDA28AA87429AD807992E22D07E014CEF36@orsmsx408>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tharbaugh@lnxi.com, netdev@oss.sgi.com,
        "Feldman, Scott" <scott.feldman@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E014CEF36@orsmsx408>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ganesh,

Can you please make this feature off by default and perhaps
accesible via ethtool for peopel who want to turn it on.
I just wasted a few hours and was bitten by this performance-wise.
Please consider disabling it.

cheers,
jamal

On Fri, 2004-06-04 at 11:44, Venkatesan, Ganesh wrote:
> Thayne:
> 
> We are studying the patch and will get back to you once we have a plan
> to integrate it into the driver.
> 
> Thanks,
> ganesh 
>  
> -------------------------------------------------
> Ganesh Venkatesan
> Network/Storage Division, Hillsboro, OR
> 
> -----Original Message-----
> From: Thayne Harbaugh [mailto:tharbaugh@lnxi.com] 
> Sent: Friday, June 04, 2004 7:20 AM
> To: netdev@oss.sgi.com
> Cc: Venkatesan, Ganesh; Feldman, Scott; Brandeburg, Jesse
> Subject: Re: [PATCH] abysmal e1000 performance (DITR)
> 
> I have documented a serious performance problem with DITR in the e1000
> driver.  I have sent a patch to the netdev list as well as CC'ed various
> people at Intel.  There has been very little response.  I am wondering
> who has reviewed the DITR performance problem and what the plans are for
> fixing it.
