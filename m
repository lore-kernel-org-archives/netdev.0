From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: PROBLEM: sky2 hangs
Date: Tue, 24 Apr 2007 09:07:28 -0700
Message-ID: <20070424090728.638e8ab7@oldman>
References: <20070424081557.1b8f6b31@oldman>
	<20070424152234.0E5E14AC6B@dcn.infos.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "Peter Trifonov" <petert@dcn.infos.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:53665 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161814AbXDXQHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 12:07:38 -0400
In-Reply-To: <20070424152234.0E5E14AC6B@dcn.infos.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 24 Apr 2007 19:22:34 +0400
"Peter Trifonov" <petert@dcn.infos.ru> wrote:

> Dear Stephen,
> 
> 
> > I bet you have 88e8056 chip.  There is some problem with the 
> Yes.
> > bus interface and the sky2 driver (and the vendor sk98lin 
> > driver), that causes all sorts of out of order device access 
> > problems.  Still investigating....
> Windows driver works perfectly with it...
>

windows is still 32 bit
> I can give you SSH access to that box if this can help you. 

Thanks but I have a system with same problem.
