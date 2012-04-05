From: Josh Boyer <jwboyer@redhat.com>
Subject: wimax: i2400m - prevent a possible kernel bug (commit 4eee6a3a04)
Date: Thu, 5 Apr 2012 07:42:46 -0400
Message-ID: <20120405114245.GD1963@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Phil Sutter <phil.sutter@viprinet.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29851 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751588Ab2DELmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2012 07:42:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I noticed you just sent another round of net patches to the stable
trees, but I didn't see commit 4eee6a3a04 included.  You might want to
include that in the next round, as we've seen it on a 3.3 kernel in
Fedora (rhbz 808603).

Just an FYI.  I'd send it to stable myself, but I believe you prefer to
handle the flow of netdev patches to stable.

josh
