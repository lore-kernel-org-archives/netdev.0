From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: sr: Use ARRAY_SIZE macro
Date: Fri, 01 Sep 2017 18:35:40 -0700 (PDT)
Message-ID: <20170901.183540.2023957151661748902.davem@davemloft.net>
References: <20170831141815.28003-1-thomas@m3y3r.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thomas@m3y3r.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170831141815.28003-1-thomas@m3y3r.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Meyer <thomas@m3y3r.de>
Date: Thu, 31 Aug 2017 16:18:15 +0200

> Grepping for "sizeof\(.+\) / sizeof\(" found this as one of the first
> candidates.
> Maybe a coccinelle can catch all of those.
> 
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>

Applied, thanks.
