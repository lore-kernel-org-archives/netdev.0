From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6 1/9] ixgb: Enabling MSI on a PCI slot (not PCI-X)
 may not work, so always disable MSI for PCI slots, enable message signalled
 interrupts on 82597EX based adapters
Date: Thu, 06 Jan 2005 21:57:23 -0500
Message-ID: <41DDFA93.9040701@pobox.com>
References: <Pine.LNX.4.44.0501061546290.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0501061546290.7330-100000@isotope.jf.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

unfortunately these ixgb patches don't apply.

Can you please resend against a vanilla 2.6.10 kernel, with no other 
patches applied?

	Jeff
