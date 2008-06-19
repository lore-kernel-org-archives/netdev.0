From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 0/4] e1000: various bug fixes for older hardware
Date: Thu, 19 Jun 2008 17:18:27 -0400
Message-ID: <20080619211827.GB22981@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36264 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396AbYFSVS3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 17:18:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These are 4 separate e1000 fixes that I've been collecting for a bit.
Of course most of this hardware is pretty old, but there are still a ton
of people using it, so it's good to get these fixes in place.

They are not dependent on each other, so feel free to comment on them
individually if you like.

None of these currently appear in the e1000 sourceforge driver, so they
will need to be added there by someone if they want them.

