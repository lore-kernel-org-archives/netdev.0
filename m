From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 0/3] Linn Ethernet Packet Sniffer driver
Date: Wed, 25 Feb 2015 18:01:27 +0100
Message-ID: <20150225170127.GD7703@localhost.localdomain>
References: <cover.1424796018.git.stathis.voukelatos@linn.co.uk>
 <20150225151945.GB7703@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stathis Voukelatos <stathis.voukelatos@linn.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150225151945.GB7703@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 25, 2015 at 04:19:45PM +0100, Richard Cochran wrote:
> Let me suggest another approach that stays in line with the existing
> frame work.  Based on the device's limitations and your own example,
> it seems clear that the intended use case is synchronization for AVB
> applications using gPTP.

Also, forgot to say, expose your clock as a PTP Hardware Clock (PHC).

Thanks,
Richard
