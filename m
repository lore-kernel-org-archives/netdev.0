From: Greg KH <greg@kroah.com>
Subject: Re: Killing USBNET as an independent Konfig option
Date: Wed, 14 Oct 2015 07:16:40 -0700
Message-ID: <20151014141640.GB30390@kroah.com>
References: <1444819531.1975.2.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55434 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753341AbbJNOQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 10:16:43 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id 2129420F6D
	for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 10:16:43 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <1444819531.1975.2.camel@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 12:45:31PM +0200, Oliver Neukum wrote:
> Hi,
> 
> would anybody mind me killing the separate config option
> of usbnet? I can see no sense in having it as a separate
> option, as it is just infrastructure.

No objection from me.
