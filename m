From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [RFC][PATCHSET] more iov_iter conversion in net/*
Date: Mon, 2 Feb 2015 08:01:01 +0000
Message-ID: <20150202080101.GV29656@ZenIV.linux.org.uk>
References: <20150131035513.GK29656@ZenIV.linux.org.uk>
 <20150201.222646.1280320067605385223.davem@davemloft.net>
 <20150202065339.GU29656@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:33000 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932979AbbBBIBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 03:01:02 -0500
Content-Disposition: inline
In-Reply-To: <20150202065339.GU29656@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 02, 2015 at 06:53:39AM +0000, Al Viro wrote:

> Al, off to figure out the proper Cc: for all those commits, so that
> git-send-email would DTRT - if I need to edit commit messages, might
> as well do that at the same time...

Done, vfs.git#for-davem force-pushed; same contents, all changes are in
commit messages.
