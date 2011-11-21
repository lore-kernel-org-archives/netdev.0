From: "Franky Lin" <frankyl@broadcom.com>
Subject: Re: [PATCH] brcm80211: smac: Use kmemdup rather than
 duplicating its implementation
Date: Mon, 21 Nov 2011 10:52:16 -0800
Message-ID: <4ECA9DE0.4080202@broadcom.com>
References: <1321569820.1624.289.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linville@tuxdriver.com" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Thomas Meyer" <thomas@m3y3r.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321569820.1624.289.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/17/2011 02:43 PM, Thomas Meyer wrote:
> The semantic patch that makes this change is available
> in scripts/coccinelle/api/memdup.cocci.
>
> Signed-off-by: Thomas Meyer<thomas@m3y3r.de>
> ---

Thanks Thomas.

Acked-by: Franky Lin <frankyl@broadcom.com>

Franky
