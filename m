From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 13/13] WE-18 (aka WPA)
Date: Tue, 15 Mar 2005 17:40:08 -0500
Message-ID: <42376448.3040701@pobox.com>
References: <200503152222.j2FMMjXu016829@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, jt@hpl.hp.com
To: akpm@osdl.org
In-Reply-To: <200503152222.j2FMMjXu016829@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Jean Tourrilhes <jt@hpl.hp.com>
> 
> This is version 18 of the Wireless Extensions.  The main change is that it
> adds all the necessary APIs for WPA and WPA2 support.  This work was
> entirely done by Jouni Malinen, so let's thank him for both his hard work
> and deep expertise on the subject ;-)
> 
> This APIs obviously doesn't do much by itself and works in concert with
> driver support (Jouni already sent you the HostAP changes) and userspace
> (Jouni is updating wpa_supplicant).  This is also orthogonal with the
> ongoing work on in-kernel IEEE support (but potentially useful).
> 
> The patch is attached, tested with 2.6.11.  Normally, I would ask you to
> push that directly in the kernel (99% of the patch has been on my web page
> for ages and it does not affect non-WPA stuff), but Jouni convinced me that
> it should bake a few weeks in wireless-2.6

Yes, this is going into wireless-2.6 later today, as requested.

	Jeff
