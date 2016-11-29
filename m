From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] debugfs: improve formatting of debugfs_real_fops()
Date: Tue, 29 Nov 2016 20:58:05 +0100
Message-ID: <20161129195805.GA2180@kroah.com>
References: <1478798629-22318-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Nicolai Stange <nicstange@gmail.com>,
        Christian Lamparter <chunkeey@gmail.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:37710 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755083AbcK2T54 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 14:57:56 -0500
Content-Disposition: inline
In-Reply-To: <1478798629-22318-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 10, 2016 at 05:23:49PM +0000, Jakub Kicinski wrote:
> Type of debugfs_real_fops() is longer than parameters and
> the name, so there is no way to break the declaration nicely.
> We have to go over 80 characters.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> ---
>  include/linux/debugfs.h | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)

Doesn't apply to my tree, what did you make this against?

thanks,

greg k-h
