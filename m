From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Hardware button support for Wireless cards
Date: Mon, 15 May 2006 16:08:22 -0400
Message-ID: <20060515200817.GC424@tuxdriver.com>
References: <!~!UENERkVCMDkAAQACAAAAAAAAAAAAAAAAAC4AAAAAAAAAWMRZS97Em0WybTChcxl4cAEALirLb4lrrkmZC6EvT+GpyAAAAABE9gAAEAAAALs6jNngvN9OooViTUM1CgIBAAAAAA==@serialmonkey.com> <e4a6lq$g5v$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([24.172.12.4]:12304 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S965210AbWEOUIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 16:08:31 -0400
To: Jason Lunz <lunz@falooley.org>
Content-Disposition: inline
In-Reply-To: <e4a6lq$g5v$1@sea.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 15, 2006 at 03:27:54PM +0000, Jason Lunz wrote:

> So if there's any desire for consistency of wireless button support,
> then I think the software-controlled ones should always shut off the
> radio, and optionally inform userspace or the wireless stack using some
> event mechanism.

FWIW, I think this position makes the most sense...

John
-- 
John W. Linville
linville@tuxdriver.com
