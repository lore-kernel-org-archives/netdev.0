From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Patch 0/5 2.4] e1000: driver update
Date: Fri, 15 Oct 2004 12:35:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416FFC3A.5050101@pobox.com>
References: <Pine.LNX.4.44.0410150524140.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0410150524140.31227-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ganesh Venkatesan wrote:
> 1. modified ethtool_set_pauseparam to use e1000_setup_link for flow control
> settings for fiber serdes link
> 2. remove unused function e1000_enable_mng_pass_thru
> 3. fix set ringparam for ethtool returning error code on bad input
> 4. driver version number update
> 5. white space corrections


all five patches in this series successfully applied to 2.4.x

	Jeff
