From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] Fix crash on big-endian systems during scan
Date: Mon, 17 Apr 2006 09:21:10 -0400
Message-ID: <20060417132105.GF5042@tuxdriver.com>
References: <20060414215911.17273.40460.stgit@dv.roinet.com> <20060417010602.GL9551@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:16913 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1750820AbWDQNV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2006 09:21:26 -0400
To: netdev@vger.kernel.org, hostap@shmoo.com,
	Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <20060417010602.GL9551@jm.kir.nu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 16, 2006 at 06:06:02PM -0700, Jouni Malinen wrote:
> On Fri, Apr 14, 2006 at 05:59:11PM -0400, Pavel Roskin wrote:
> 
> > The original code was doing arithmetics on a little-endian value.
> 
> John, please apply this to wireless-2.6 tree. This code is triggered at
> least for the case where WPA is not used. I had noticed it before, but I
> think I've only tested WPA/WPA2 on big endian systems..

Can someone repost this patch?  I seem to have missed it.

Thanks,

John
-- 
John W. Linville
linville@tuxdriver.com
