From: vadim4j@gmail.com
Subject: Re: [PATCH iproute2] ss: Refactor to use macro for define diag nl
 request
Date: Sun, 19 Oct 2014 10:09:13 +0300
Message-ID: <20141019070913.GA27249@angus-think.lan>
References: <1413676229-23258-1-git-send-email-vadim4j@gmail.com>
 <20141019113920.3f0fa575@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:54019 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbaJSHSJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Oct 2014 03:18:09 -0400
Received: by mail-la0-f42.google.com with SMTP id gf13so2795431lab.1
        for <netdev@vger.kernel.org>; Sun, 19 Oct 2014 00:18:07 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20141019113920.3f0fa575@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 19, 2014 at 11:39:20AM +0530, Stephen Hemminger wrote:
> 
> No need to initialize to zero.
> 

OK, will remove and resend it.

Thanks.
