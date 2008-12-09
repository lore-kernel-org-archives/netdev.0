From: Manfred Spraul <manfred@colorfullife.com>
Subject: Re: Nasty regression from .27.7 to .27.8: idle samba goes crazy
Date: Tue, 09 Dec 2008 20:16:34 +0100
Message-ID: <493EC412.3090805@colorfullife.com>
References: <pan.2008.12.08.06.18.57.357875@wizards.de> <200812080834.22924.rjw@sisk.pl> <pan.2008.12.08.08.07.29.439625@wizards.de> <493D4F5C.7020606@s5r6.in-berlin.de> <493D7349.10200@s5r6.in-berlin.de> <20081208222246.GA29232@sith.mimuw.edu.pl> <20081209123703.043067eb@dhcp-100-2-144.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jan Rekorajski <baggins@sith.mimuw.edu.pl>,
	linux-kernel@vger.kernel.org,
	Holger Hoffstaette <holger@wizards.de>, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Greg KH <greg@kroah.com>,
	stable@kernel.org, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Nadia Derbey <Nadia.Derbey@bull.net>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f13.google.com ([209.85.218.13]:59549 "EHLO
	mail-bw0-f13.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754184AbYLITjZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 14:39:25 -0500
Received: by bwz6 with SMTP id 6so215434bwz.13
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 11:39:22 -0800 (PST)
In-Reply-To: <20081209123703.043067eb@dhcp-100-2-144.bos.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Ebbert wrote:
> Try reverting the idr patch that went into 2.6.27.8. It broke DRM in the
> Fedora kernel at least.
>
>   
What happens?
Does it oops, does one of the BUG() statements trigger?

--
    Manfred
