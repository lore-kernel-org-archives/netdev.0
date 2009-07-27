From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] at1700: Read buffer overflow
Date: Sun, 26 Jul 2009 19:01:38 -0700 (PDT)
Message-ID: <20090726.190138.238561889.davem@davemloft.net>
References: <4A6B80CE.6060702@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44674
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755682AbZG0CBc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2009 22:01:32 -0400
In-Reply-To: <4A6B80CE.6060702@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Sun, 26 Jul 2009 00:01:50 +0200

> loop bound looks to be wrong, for an array of length 8
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Applied.
