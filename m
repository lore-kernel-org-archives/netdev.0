From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: tile: fix unused variable warning
Date: Mon, 16 Jun 2014 21:46:07 +0400
Message-ID: <539F2D5F.9000708@cogentembedded.com>
References: <201406161716.s5GHGkKq026867@farm-0039.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Chris Metcalf <cmetcalf@tilera.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201406161716.s5GHGkKq026867@farm-0039.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 06/16/2014 09:14 PM, Chris Metcalf wrote:

> 'i' is unused in tile_net_dev_init() after commit d581ebf5a1f.

    Please also specify that commit's summary line in parens.

> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

WBR, Sergei
