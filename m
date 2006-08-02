From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH 0/5] d80211: pull request
Date: Tue, 1 Aug 2006 22:11:41 -0400
Message-ID: <20060802021136.GA23066@tuxdriver.com>
References: <20060801211530.150852000.midnight@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:39175 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750971AbWHBCL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 22:11:57 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060801211530.150852000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 09:16:54PM +0200, Jiri Benc wrote:
> Please pull from
> git://git.kernel.org/pub/scm/linux/kernel/git/jbenc/dscape.git up
> to obtain following patches:
> 
> Jiri Benc:
>       d80211: make sleeping in hw->config possible
>       d80211: return correct error codes for scan requests
>       d80211: Switch d80211 drivers to IEEE80211_ style definitions
> 
> Karol Lewandowski:
>       d80211: return correct value when loading of rate control module fails
> 
> Michael Wu:
>       d80211: Switch d80211 to IEEE80211_ style names

Pulled and available in wireless-dev.  No fancy announcment, since
all I did was pull Jiri's stuff.

John
-- 
John W. Linville
linville@tuxdriver.com
