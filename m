From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2 1/6] net/ethernet/atl1c: Disable ASPM on various
 chipsets
Date: Mon, 14 Nov 2011 00:30:48 -0500 (EST)
Message-ID: <20111114.003048.2051399548192848039.davem@davemloft.net>
References: <1321028064-644-1-git-send-email-mjg@redhat.com>
	<1321028064-644-2-git-send-email-mjg@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jcliburn@gmail.com, chris.snook@gmail.com
To: mjg@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321028064-644-2-git-send-email-mjg@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthew Garrett <mjg@redhat.com>
Date: Fri, 11 Nov 2011 11:14:19 -0500

> The Windows driver disables ASPM support for various chipsets supported
> by atl1c. This adds the same set of logic to the Linux driver. ASPM is
> disabled on l1c, l2c, l2cb and l2cb2 devices except for those in Toshiba
> or Lenovo devices. Data taken from
> http://www.atheros.cz/atheros-inf-file.php?inf=199&chipset=51&system=6
> 
> Signed-off-by: Matthew Garrett <mjg@redhat.com>

Applied.
