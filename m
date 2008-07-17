From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [Resend PATCH 2/3] TCP: options clean up
Date: Thu, 17 Jul 2008 16:04:19 -0700
Message-ID: <396556a20807171604p5c20056eja34aa3f9303482c6@mail.gmail.com>
References: <396556a20805301217k293e5718h6bbf02bfe069012@europa>
	 <20080716.204615.94767359.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.238]:10301 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755210AbYGQXEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 19:04:20 -0400
Received: by rv-out-0506.google.com with SMTP id k40so106007rvb.1
        for <netdev@vger.kernel.org>; Thu, 17 Jul 2008 16:04:20 -0700 (PDT)
In-Reply-To: <20080716.204615.94767359.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2008 at 8:46 PM, David Miller <davem@davemloft.net> wrote:
> Those changes should make this structure 8 bytes.

Made all those changes, although the couple of timestamps means that
the struct is > 8 bytes still.


AGL

-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
