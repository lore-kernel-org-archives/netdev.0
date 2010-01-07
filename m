From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/media/dvb/dvb-core/dvb_net.c: use %pM to show
 MAC address
Date: Thu, 07 Jan 2010 01:17:47 -0800 (PST)
Message-ID: <20100107.011747.54958411.davem@davemloft.net>
References: <201001050945.21446.hartleys@visionengravers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-media@vger.kernel.org
To: hartleys@visionengravers.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932962Ab0AGJRs@vger.kernel.org>
In-Reply-To: <201001050945.21446.hartleys@visionengravers.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: H Hartley Sweeten <hartleys@visionengravers.com>
Date: Tue, 5 Jan 2010 09:45:21 -0700

> Use the %pM kernel extension to display the MAC address and mask.
> 
> The only difference in the output is that the output is shown in
> the usual colon-separated hex notation.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied.
