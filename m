From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/3] sky2: tx pause bug fix
Date: Tue, 19 Sep 2006 13:31:59 -0700
Message-ID: <20060919133159.27165976@localhost.localdomain>
References: <20060906124447.642940bd@localhost.localdomain>
	<01cb01c6d542$88544620$5001010a@bluereef.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20117 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752053AbWISUcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 16:32:07 -0400
To: "Andrew Hall" <andrew.hall@bluereefnetworks.com>
In-Reply-To: <01cb01c6d542$88544620$5001010a@bluereef.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 11 Sep 2006 11:35:11 +1000
"Andrew Hall" <andrew.hall@bluereefnetworks.com> wrote:

> Stephen,
> 
> After some serious testing, this patch seems to fix the lockup issue 
> completely. I manually applied these changes against the 2.6.17.13 release.

Any more problems?
