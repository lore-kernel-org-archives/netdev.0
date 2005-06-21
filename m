From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 21 Jun 2005 13:55:00 -0700 (PDT)
Message-ID: <20050621.135500.35467865.davem@davemloft.net>
References: <42A5284C.3060808@osdl.org>
	<20050621.132044.115910664.davem@davemloft.net>
	<42B87ACF.3080800@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, mitch.a.williams@intel.com, john.ronciak@intel.com,
        mchan@broadcom.com, hadi@cyberus.ca, buytenh@wantstofly.org,
        jdmason@us.ibm.com, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rick.jones2@hp.com
In-Reply-To: <42B87ACF.3080800@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 21 Jun 2005 13:38:39 -0700

> > I highly recommend that this gets fixed.
> 
> What is the cut-off point for the copy?

256 has been found to be a well functioning value to use.
