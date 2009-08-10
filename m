From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] atlx: strncpy does not null terminate string
Date: Sun, 09 Aug 2009 21:52:58 -0700 (PDT)
Message-ID: <20090809.215258.03151417.davem@davemloft.net>
References: <200908062306.n76N6ug6007294@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, csnook@redhat.com, jie.yang@atheros.com,
	netdev@vger.kernel.org, roel.kluin@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50012
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752062AbZHJEws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:52:48 -0400
In-Reply-To: <200908062306.n76N6ug6007294@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 06 Aug 2009 16:06:56 -0700

> From: Roel Kluin <roel.kluin@gmail.com>
> 
> strlcpy() will always null terminate the string.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied.
