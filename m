From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][E1000E] some cleanups
Date: Tue, 09 Oct 2007 18:18:49 -0400
Message-ID: <1191968329.5324.42.camel@localhost>
References: <1191174077.6165.11.camel@localhost>
	 <47028351.7090509@intel.com>  <1191417498.4357.23.camel@localhost>
	 <1191773723.4394.31.camel@localhost>  <470AB1EC.2080000@intel.com>
	 <1191936581.4373.192.camel@localhost>  <470BA602.7060400@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.245]:25170 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459AbXJIWSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 18:18:54 -0400
Received: by ag-out-0708.google.com with SMTP id 35so862321aga
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2007 15:18:54 -0700 (PDT)
In-Reply-To: <470BA602.7060400@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-09-10 at 09:02 -0700, Kok, Auke wrote:
> 
> if we're going to remove LLTX from e1000 I prefer to do that at a much later time.
> Let's focus on e1000e instead - while it is still moving ;)

I think you may be in luck ;-> I just saw a patch posted by jgarzik
which touched both e1000/e LLTX. I am on travel mode starting tommorow,
I will try to extract it on my laptop while on the road but cant test
it.

cheers,
jamal

