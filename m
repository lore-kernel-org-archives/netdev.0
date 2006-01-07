From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC: 2.6 patch] net/ipv4/ip_output.c: make ip_fragment()
 static
Date: Sat, 07 Jan 2006 13:23:51 -0800 (PST)
Message-ID: <20060107.132351.132009164.davem@davemloft.net>
References: <20060107181533.GO3774@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030585AbWAGVYH@vger.kernel.org>
To: bunk@stusta.de
In-Reply-To: <20060107181533.GO3774@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Sat, 7 Jan 2006 19:15:33 +0100

> Since there's no longer any external user of ip_fragment() we can make 
> it static.
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Works for me, applied.

Thanks.
