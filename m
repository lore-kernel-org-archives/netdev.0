From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [PATCH 0/6] more sky2 patches for 2.6.16.42-rc1
Date: Mon, 26 Feb 2007 15:35:48 +0100
Message-ID: <20070226143548.GN29575@stusta.de>
References: <20070223231042.860031000@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:44668 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1030290AbXBZOfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 09:35:47 -0500
Content-Disposition: inline
In-Reply-To: <20070223231042.860031000@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 23, 2007 at 03:10:42PM -0800, Stephen Hemminger wrote:
> More backport of sky2 stuff.
> 	* [bugfix] ram buffer setup
> 	* [bugfix] listen to pause packets
> 	* [bugfix] big endian
> 	
> Optional:
> 	* add more statistics (add entries to table)
> 	* add more pci-ids for newer boards
> 	* update version and email address

Thanks, I've applied all 6 patches.

> Stephen Hemminger

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

