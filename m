From: Matt Mackall <mpm@selenic.com>
Subject: Re: [BUG] netpoll is unable to handle skb's using packet split
Date: Mon, 14 Nov 2005 21:23:58 -0800
Message-ID: <20051115052358.GG31287@waste.org>
References: <9929d2390511141315t2fb15b2aucbbebcbe4cec7ef1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751327AbVKOFY4@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Content-Disposition: inline
In-Reply-To: <9929d2390511141315t2fb15b2aucbbebcbe4cec7ef1@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 14, 2005 at 01:15:38PM -0800, Jeff Kirsher wrote:
> When using packet split, netpoll times out when doing a netdump.

What is "packet split" in this context? You ought to cc: the netdump
people as well, as it's not part of the mainline kernel.

-- 
Mathematics is the supreme nostalgia of our time.
