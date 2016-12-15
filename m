From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH] net: sfc: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 15 Dec 2016 17:18:04 +0000
Message-ID: <dd794453-4020-94c0-b73f-622cb6258ff6@solarflare.com>
References: <1481757173-16000-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
        <linux-net-drivers@solarflare.com>, <ecree@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481757173-16000-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/12/16 23:12, Philippe Reynes wrote:
> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Tested-by: Bert Kenward <bkenward@solarflare.com>
Acked-by: Bert Kenward <bkenward@solarflare.com>
