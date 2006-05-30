From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: skge driver oops
Date: Tue, 30 May 2006 11:25:47 -0700
Message-ID: <20060530112547.0f9007f4@localhost.localdomain>
References: <BB1F4EFD574E9F409035BDA71C9612500241B7@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "'Krzysztof Oledzki'" <olel@ans.pl>, netdev@vger.kernel.org,
	"'david@mantara.com'" <david@mantara.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:18391 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932298AbWE3S0H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 14:26:07 -0400
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
In-Reply-To: <BB1F4EFD574E9F409035BDA71C9612500241B7@exchange.i-bn>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 May 2006 19:54:01 +0200
Beschorner Daniel <Daniel.Beschorner@facton.com> wrote:

> Hi Stephen,
> 
> the patch doesn't help.
> As soon as the card is receiving lots of data, the box crashes after some
> seconds.
> Testing these patches is very tricky for me, as it is a production system at
> a remote location crashing on every test.
> 
> It's a D-Link card, ID 4C00 (530T), SysKonnect's driver is working fine.

I assume you sk98lin version downloaded from their web site.
