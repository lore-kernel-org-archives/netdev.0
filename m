From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: ICS1883 LAN PHY not detected
Date: Sat, 02 Apr 2005 20:25:04 -0500
Message-ID: <424F45F0.1000504@pobox.com>
References: <424EF19B.7030105@cogweb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: venza@brownhat.org, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261413AbVDCBZb@vger.kernel.org>
To: David Liontooth <liontooth@cogweb.net>
In-Reply-To: <424EF19B.7030105@cogweb.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Liontooth wrote:
> 0000:02:0b.0 Ethernet controller: Marvell Technology Group Ltd. Yukon 
> Gigabit Ethernet 10/100/1000Base-T Adapter (rev 13)


You want the sk98lin or skge drivers.

	Jeff
