From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.11] WE-18 (aka WPA)
Date: Tue, 22 Mar 2005 17:57:43 -0500
Message-ID: <4240A2E7.50308@pobox.com>
References: <20050314201932.GA1467@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jouni Malinen <jkmaline@cc.hut.fi>, netdev@oss.sgi.com,
        Linux kernel mailing list <linux-kernel@vger.kernel.org>
To: jt@hpl.hp.com
In-Reply-To: <20050314201932.GA1467@bougret.hpl.hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jean Tourrilhes wrote:
> 	Hi Jeff,
> 
> 	This is version 18 of the Wireless Extensions. The main change
> is that it adds all the necessary APIs for WPA and WPA2 support. This
> work was entirely done by Jouni Malinen, so let's thank him for both
> his hard work and deep expertise on the subject ;-)
> 	This APIs obviously doesn't do much by itself and works in
> concert with driver support (Jouni already sent you the HostAP
> changes) and userspace (Jouni is updating wpa_supplicant). This is
> also orthogonal with the ongoing work on in-kernel IEEE support (but
> potentially useful).
> 	The patch is attached, tested with 2.6.11. Normally, I would
> ask you to push that directly in the kernel (99% of the patch has been
> on my web page for ages and it does not affect non-WPA stuff), but
> Jouni convinced me that it should bake a few weeks in wireless-2.6
> first, so that other driver maintainers can get up to speed with it.
> 
> 	So, would you mind pushing that in wireless-2.6 ?
> 	Thanks in advance...

Applied to wireless-2.6, and will soon push upstream.

NOTE:  Please include a Signed-off-by line in ALL patches that you submit.

See http://linux.yyz.us/patch-format.html for more info.

	Jeff
