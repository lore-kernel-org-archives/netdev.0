From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] deinline 200+ byte inlines in sock.h
Date: Thu, 30 Mar 2006 00:08:02 -0800 (PST)
Message-ID: <20060330.000802.55613013.davem@davemloft.net>
References: <200603301026.24864.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751334AbWC3IHj@vger.kernel.org>
To: vda@ilport.com.ua
In-Reply-To: <200603301026.24864.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Denis Vlasenko <vda@ilport.com.ua>
Date: Thu, 30 Mar 2006 10:26:24 +0300

> We have 200+ byte inlines in sock.h. That's way too large
> in my opinion.

In Linus's tree already.

Would you please check the relevant trees before re-posting patches?
Thanks a lot.
