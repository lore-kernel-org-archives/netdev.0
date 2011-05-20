From: Luciano Coelho <coelho@ti.com>
Subject: Re: [RFC/PATCH 04/13] net: wl12xx: care for optional operations
Date: Fri, 20 May 2011 15:03:26 +0300
Message-ID: <1305893006.12586.1665.camel@cumari>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
	 <1305321990-22041-5-git-send-email-balbi@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Felipe Balbi <balbi@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305321990-22041-5-git-send-email-balbi@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2011-05-14 at 00:26 +0300, Felipe Balbi wrote:
> ->init and ->reset are optional - at least
> sdio.c doesn't implement them - so allow those
> pointers to be NULL.
> 
> Signed-off-by: Felipe Balbi <balbi@ti.com>
> ---

Applied.

-- 
Cheers,
Luca.
