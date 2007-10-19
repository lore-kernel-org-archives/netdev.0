From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: networking crash in current mainline:
 sk_filter_delayed_uncharge()
Date: Thu, 18 Oct 2007 23:12:09 -0700
Message-ID: <20071018231209.ffb27828.akpm@linux-foundation.org>
References: <20071018230948.959e89d1.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>
To: netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50972 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758480AbXJSGMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 02:12:14 -0400
In-Reply-To: <20071018230948.959e89d1.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Oct 2007 23:09:48 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> 
> powerpc mac G5
> config: http://userweb.kernel.org/~akpm/config-g5.txt
> screenshot: http://userweb.kernel.org/~akpm/dsc00005.jpg
> 
> It does this shortly after bringing up eth0 (tg3), in dhclient.
> 

<looks in the git tree, adds cc ;)>
