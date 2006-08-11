From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: the mystery that is sock_fasync
Date: Fri, 11 Aug 2006 14:28:20 +0400
Message-ID: <20060811102820.GA10816@2ka.mipt.ru>
References: <20060811.031516.38316536.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:10959 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932084AbWHKK2k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 06:28:40 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060811.031516.38316536.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 11, 2006 at 03:15:16AM -0700, David Miller (davem@davemloft.net) wrote:
> Did I miss some way that multiple file objects can point to the
> same socket inode?

What about dup and pipe?

-- 
	Evgeniy Polyakov
