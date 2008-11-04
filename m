From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [RESEND] benet: BladeEngine 10Gb NIC driver
Date: Tue, 4 Nov 2008 12:41:36 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811041237400.23792@wrl-59.cs.helsinki.fi>
References: <20081103122512.06063fc9@mailhost.serverengines.com>
 <20081103193641.GA12552@kroah.com> <490F5667.3080904@garzik.org>
 <20081103201930.GB13299@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Subbu Seetharaman <subbus@serverengines.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60145 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbYKDKlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 05:41:39 -0500
In-Reply-To: <20081103201930.GB13299@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 Nov 2008, Greg KH wrote:

> Hm, call me extreemly stupid, but I don't see anything in that branch
> for this driver.
> 
> Here's what I did:
>   git fetch git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git benet master:jeff

I suppose you'd have needed instead of "benet master:jeff" just:

benet:jeff

Ie., from benet remote branch to jeff local branch (remote from the given
repository obviously). ...Then you have that jeff branch and can checkout 
it.

-- 
 i.
