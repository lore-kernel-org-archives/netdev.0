From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: [RFC] mark MD5 as broken in older (stable) kernels
Date: Wed, 9 Jul 2008 10:01:26 -0700
Message-ID: <396556a20807091001l2740f959jf24860ae42aadb9c@mail.gmail.com>
References: <396556a20807071021n2039fc8eo6ab343355e36b468@mail.gmail.com>
	 <396556a20805301217k293e5718h6bbf02bfe069001@europa>
	 <20080709095851.1f9da054@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Stephen Hemminger" <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:28669 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbYGIRB1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 13:01:27 -0400
Received: by rv-out-0506.google.com with SMTP id k40so3629693rvb.1
        for <netdev@vger.kernel.org>; Wed, 09 Jul 2008 10:01:26 -0700 (PDT)
In-Reply-To: <20080709095851.1f9da054@speedy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 9, 2008 at 9:58 AM, Stephen Hemminger
<stephen.hemminger@vyatta.com> wrote:
> The following should probably be sent to stable kernel tree to disable
> MD5 in older kernels. It will avoid problems for all those vendor
> kernels.

Acked-By: Adam Langley <agl@imperialviolet.org>


-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
