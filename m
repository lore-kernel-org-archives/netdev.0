From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [Patch 1/5 2.5] e100: Fix e100_watchdog to not accidentally re-enable
 interrupts when setting the software interrupt bit.
Date: Fri, 15 Oct 2004 12:24:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <416FF9AE.20304@pobox.com>
References: <Pine.LNX.4.44.0410150549450.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0410150549450.31227-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I'm afraid these patches did not apply, due to the pre-existing e100 
patches that have already been applied.

Please re-diff and resend this patch series against the netdev-2.6 patch 
that I just posted (and CC'd to you).

	Jeff
