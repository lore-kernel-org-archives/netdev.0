From: Luciano Coelho <coelho@ti.com>
Subject: Re: [RFC/PATCH 01/13] net: wl12xx: sdio: id_tables should be
 __devinitconst
Date: Fri, 20 May 2011 15:02:45 +0300
Message-ID: <1305892965.12586.1663.camel@cumari>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
	 <1305321990-22041-2-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305321990-22041-2-git-send-email-balbi@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2011-05-14 at 00:26 +0300, Felipe Balbi wrote:
> That's only needed during init anyway, let's free
> some space after we're done probing.
> 
> Signed-off-by: Felipe Balbi <balbi@ti.com>
> ---

Applied, this one.  Thanks, Felipe!

-- 
Cheers,
Luca.
