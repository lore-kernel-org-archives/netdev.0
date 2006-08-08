From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: 2.6.18-rc3-mm2: bad e1000 device name
Date: Tue, 08 Aug 2006 09:17:43 -0700
Message-ID: <44D8B927.6010905@goop.org>
References: <44D78A48.7050707@goop.org> <20060808004011.ab3cd65f.akpm@osdl.org> <44D8484E.9050904@goop.org> <44D8AB08.3000006@linux.intel.com> <44D8ACFE.3060802@goop.org> <44D8AD3D.60402@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:22481 "EHLO mail.goop.org")
	by vger.kernel.org with ESMTP id S964925AbWHHQRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2006 12:17:34 -0400
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <44D8AD3D.60402@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> and you're also sure this is not your userspace using interface 
> renaming...
> (could be an initscripts bug for name-by-MAC ethernet device naming)

It's definitely in-kernel, since its specific to this version.  And it 
seems to have gone away since I turned on slab debugging.

    J
