From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [resend][PATCH net-drivers-2.4 12/16] e1000: Modified e1000_clean::
 exit poll
Date: Fri, 19 Aug 2005 02:22:08 -0400
Message-ID: <43057A90.6000302@pobox.com>
References: <Pine.LNX.4.44.0504282004300.30085-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Malli Chilakala <mallikarjuna.chilakala@intel.com>
In-Reply-To: <Pine.LNX.4.44.0504282004300.30085-100000@isotope.jf.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Malli Chilakala wrote:
> Modified e1000_clean:: exit poll if no Tx and work_done == 0
> 
> Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
> Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
> Signed-off-by: John Ronciak <john.ronciak@intel.com>

Applied e1000 patches 1-12 to 2.4.x.  Stopped at this patch.

Patch 13 was corrupted, so that's where the import stopped.

But nonetheless... 2.4.x netdev patches are flowing again!

	Jeff
