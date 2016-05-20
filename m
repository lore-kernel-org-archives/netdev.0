From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] ptp: use memdup_user().
Date: Fri, 20 May 2016 14:54:17 +0200
Message-ID: <20160520125417.GA3559@localhost.localdomain>
References: <1463746862-23815-1-git-send-email-falakreyaz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open list:PTP HARDWARE CLOCK SUPPORT" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Muhammad Falak R Wani <falakreyaz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35140 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755632AbcETMyW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 08:54:22 -0400
Content-Disposition: inline
In-Reply-To: <1463746862-23815-1-git-send-email-falakreyaz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 20, 2016 at 05:51:02PM +0530, Muhammad Falak R Wani wrote:
> Use memdup_user to duplicate a memory region from user-space to
> kernel-space, instead of open coding using kmalloc & copy_from_user.
> 
> Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
