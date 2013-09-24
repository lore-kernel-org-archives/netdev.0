From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net v4 1/1] xen-netback: Handle backend state transitions
 in a more robust way
Date: Tue, 24 Sep 2013 17:12:55 +0100
Message-ID: <20130924161255.GC14211@zion.uk.xensource.com>
References: <1380037500-12174-1-git-send-email-paul.durrant@citrix.com>
 <1380037500-12174-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:64642 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab3IXQM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:12:56 -0400
Content-Disposition: inline
In-Reply-To: <1380037500-12174-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You forgot to fix those typos -- metback, transtions. :-)

On Tue, Sep 24, 2013 at 04:45:00PM +0100, Paul Durrant wrote:
> When the frontend state changes metback now specifies its desired state to

metback

[...]
> + * The backend state starts in InitWait and the following transtions are

transtions

Wei.
