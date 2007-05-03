From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] SAD info TLV aggregation
Date: Thu, 03 May 2007 09:26:04 -0400
Message-ID: <1178198764.4077.30.camel@localhost>
References: <1178144288.4078.5.camel@localhost> <4639298E.8090100@trash.net>
	 <1178197316.4077.4.camel@localhost>  <4639E08F.5030101@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:26221 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754114AbXECN0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 09:26:09 -0400
Received: by wx-out-0506.google.com with SMTP id h31so438162wxd
        for <netdev@vger.kernel.org>; Thu, 03 May 2007 06:26:09 -0700 (PDT)
In-Reply-To: <4639E08F.5030101@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-03-05 at 15:15 +0200, Patrick McHardy wrote:

> > 
> > I think it may be reasonable to group the Hash info in one TLV
> > and the IPSEC specific info in a separate TLV - is this what you are
> > saying? Be explicit so i dont have to redo the patch over and over.
> 
> Yes, thats what I imagined too.

Ok, thanks Patrick - indeed it is a wise thing to do to improve
longevity of user space.

I will make those two changes sometime tonight or tommorow morn
and resend.

cheers,
jamal

