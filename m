From: Chuck Ebbert <76306.1226@compuserve.com>
Subject: Re: -mm -> 2.6.13 merge status (dropped patches?)
Date: Thu, 30 Jun 2005 16:02:51 -0400
Message-ID: <200506301605_MC3-1-A320-D9D6@compuserve.com>
Mime-Version: 1.0
Content-Type: text/plain;
	 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263066AbVF3Uep@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Jun 2005 at 23:54:58 -0700, Andrew Morton wrote:

> This summarises my current thinking on various patches which are presently
> in -mm.  I cover large things and small-but-controversial things.  Anything
> which isn't covered here (and that's a lot of material) is probably a "will
> merge", unless it obviously isn't.

What happened to:

        remove-last_rx-update-from-loopback-device.patch

It was dropped in 2.6.12-rc1-mm4 with a status of "merged" but it's not
in either 2.6.12 or 2.6.13-rc1.

And in general, who is tracking whether things are being lost?


--
Chuck
