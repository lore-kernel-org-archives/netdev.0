From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: Re: [PATCHv2] fs_enet: restore promiscuous and multicast settings
 in restart()
Date: Thu, 26 Jun 2008 17:56:14 +0400
Message-ID: <20080626175614.57ea5bbe@vitb.ru.mvista.com>
References: <200806261148.26569.laurentp@cse-semaphore.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	pantelis.antoniou@gmail.com,
	"Matvejchikov Ilya" <matvejchikov@gmail.com>
To: Laurent Pinchart <laurentp@cse-semaphore.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:35876 "EHLO
	vitb.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752000AbYFZPA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 11:00:59 -0400
In-Reply-To: <200806261148.26569.laurentp@cse-semaphore.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Jun 2008 11:48:22 +0200
Laurent Pinchart <laurentp@cse-semaphore.com> wrote:

> The restart() function is called when the link state changes and resets
> multicast and promiscuous settings. This patch restores those settings at the
> end of restart().
> 
> Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
Acked-by: Vitaly Bordug <vitb@kernel.crashing.org>



-- 
Sincerely, 
Vitaly
