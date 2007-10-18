From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2] r8169 - trivial fixes - add KERN_DEBUG to dprintk
Date: Thu, 18 Oct 2007 21:09:26 +0200
Message-ID: <20071018190926.GB8594@electric-eye.fr.zoreil.com>
References: <1192734097.23980.37.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58148 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753991AbXJRTNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 15:13:22 -0400
Content-Disposition: inline
In-Reply-To: <1192734097.23980.37.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> :
> Prefix dprintk with KERN_DEBUG
> Fix a bug with existing use of dprintk (PFX KERN_INFO PFX)
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Ok, I will add #1 and #2 to the next submission to Jeff.

-- 
Ueimor
