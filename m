From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BUG] netpoll is unable to handle skb's using packet split
Date: Mon, 14 Nov 2005 21:39:22 -0800 (PST)
Message-ID: <20051114.213922.16377460.davem@davemloft.net>
References: <9929d2390511141315t2fb15b2aucbbebcbe4cec7ef1@mail.gmail.com>
	<20051115052358.GG31287@waste.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751294AbVKOFjP@vger.kernel.org>
To: mpm@selenic.com
In-Reply-To: <20051115052358.GG31287@waste.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matt Mackall <mpm@selenic.com>
Date: Mon, 14 Nov 2005 21:23:58 -0800

> What is "packet split" in this context?

It's a mode of buffering used by the e1000 driver.
