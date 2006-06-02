From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Driver for Rsltek 8139D / Silan SC92031
Date: Fri, 2 Jun 2006 13:28:46 -0700
Message-ID: <20060602132846.2ee6c71a@localhost.localdomain>
References: <44809CB5.50501@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cantao@thorus-scisoft.com.br
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50074 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932563AbWFBU2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 16:28:50 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <44809CB5.50501@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 02 Jun 2006 21:16:53 +0100
Daniel Drake <dsd@gentoo.org> wrote:

> Here's a strange one. Cantao (on CC) bought what he thought was a cheap 
> realtek PCI NIC, it actually turns out it is a Rsltek (yes, Rsltek) 
> 8139D card.
> 
> It includes an old (2.4/2.5) driver which claims to be for Silan SC92031 
> (attached).
> 
> The driver has some very obvious similarities with 8139too, however the 
> register layout and usage is quite different.
> 
> Has anyone got any idea whats going on here? It seems like something 
> based on a realtek chip, but not...
> 
> Daniel
> 

It certainly is a good driver as is...
