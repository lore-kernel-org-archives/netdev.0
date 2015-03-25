From: David Miller <davem@davemloft.net>
Subject: Re: commit 957f094f221f for 3.19.y stable
Date: Wed, 25 Mar 2015 14:10:36 -0400 (EDT)
Message-ID: <20150325.141036.1599612527230435086.davem@davemloft.net>
References: <CA+5PVA7da0VBi0Cho1m6UoKh0-hqiVYgJbmTU28FnXznkgk7Tg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	gregkh@linuxfoundation.org
To: jwboyer@fedoraproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752189AbbCYSKj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 14:10:39 -0400
In-Reply-To: <CA+5PVA7da0VBi0Cho1m6UoKh0-hqiVYgJbmTU28FnXznkgk7Tg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josh Boyer <jwboyer@fedoraproject.org>
Date: Wed, 25 Mar 2015 13:21:33 -0400

> We had a report[1] that 3.19 broke the Juniper VPN.  Commit
> 957f094f221f (tun: return proper error code from tun_do_read) was
> identified as the fix and tested successfully on top of 3.19.2.  I
> noticed it wasn't included in your latest set of patches for the
> stable trees.  I don't believe it's something you have queued in your
> stable mbox on patchwork either.  Is this something that should be
> queued up for stable?
> 
> josh
> 
> [1] http://bugzilla.redhat.com/1204512

Ok queued up for my next batch of -stable submissions, thanks.
