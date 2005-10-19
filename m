From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] skge support for Marvell chips in Toshiba laptops
Date: Wed, 19 Oct 2005 12:58:30 -0700
Message-ID: <200510191258.31316.jbarnes@virtuousgeek.org>
References: <200510191047.53212.jbarnes@virtuousgeek.org> <4356A1F5.5010200@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751270AbVJST6p@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4356A1F5.5010200@gentoo.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, October 19, 2005 12:43 pm, Daniel Drake wrote:
> The device ID you added (0x4351) is already claimed by the new sky2
> driver.
>
> Unless theres a mistake in sky2's device table, your laptop contains a
> Yukon-II adapter which is incompatible with the original Yukon chips
> (skge = Yukon, sky2 = Yukon-II).
>
> On the other hand, I believe Stephen could do with some extra sky2
> testing :) You can find it in the latest -mm releases.

Oh cool, I'll try that driver instead.  Thanks.

Jesse
