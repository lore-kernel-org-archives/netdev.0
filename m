From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: Re: [PATCH -stable] multiple backports requested
Date: Sat, 14 Nov 2015 06:34:15 -0500
Message-ID: <1447500855.2645.18.camel@gmail.com>
References: <1447445591.2645.17.camel@gmail.com>
	 <20151113.161032.1223894063965320473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:35761 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbbKNLeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2015 06:34:17 -0500
Received: by qkao63 with SMTP id o63so72677090qka.2
        for <netdev@vger.kernel.org>; Sat, 14 Nov 2015 03:34:17 -0800 (PST)
In-Reply-To: <20151113.161032.1223894063965320473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-11-13 at 16:10 -0500, David Miller wrote:
> From: "Charles (Chas) Williams" <3chas3@gmail.com>
> Date: Fri, 13 Nov 2015 15:13:11 -0500
> 
> > Dave, could you please add the following backports?
> > 
> > For the 3.14.y stable queue:
> 
> I am no longer handling 3.14.y -stable submissions, sorry...
> 
> > For the 4.1.y stable queue:
> > 
> > 	commit 74e98eb085889b0d2d4908f59f6e00026063014f
> > 	RDS: verify the underlying transport exists before creating a connection
> > 	This addresses CVE-2015-6937
> 
> Queued up for 3.18, 4.1, and 4.2.

And 3.14?
