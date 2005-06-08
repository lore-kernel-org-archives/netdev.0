From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Tue, 07 Jun 2005 20:31:51 -0700 (PDT)
Message-ID: <20050607.203151.55506965.davem@davemloft.net>
References: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408>
	<20050607.132159.35660612.davem@davemloft.net>
	<Pine.LNX.4.62.0506071852290.31708@ladlxr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.ronciak@intel.com, hadi@cyberus.ca, shemminger@osdl.org,
        mitch.a.williams@intel.com, mchan@broadcom.com, buytenh@wantstofly.org,
        jdmason@us.ibm.com, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jesse.brandeburg@intel.com
In-Reply-To: <Pine.LNX.4.62.0506071852290.31708@ladlxr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date: Tue, 7 Jun 2005 19:20:37 -0700 (PDT)

> I'm looking forward to trying the split out patches tomorrow.

Don't get too excited, those are purely bug fixes and don't
actually do the actual "Super TSO" part yet.  I'm trying to
test the cleanups leading up to the actual TSO segmenting change
to make sure any such regressions therein get weeded out.
