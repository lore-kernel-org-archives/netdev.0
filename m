From: David Dillow <dave@thedillows.org>
Subject: Re: [PATCH] 2.6.25 typhoon_resume - remove call to start_queue
Date: Mon, 21 Apr 2008 10:35:24 -0400
Message-ID: <1208788524.5295.6.camel@lap75545.ornl.gov>
References: <20080421044415.GB15080@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lap75545.ornl.gov ([160.91.210.54]:35889 "EHLO
	lap75545.ornl.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbYDUO5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 10:57:18 -0400
In-Reply-To: <20080421044415.GB15080@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sun, 2008-04-20 at 22:44 -0600, Grant Grundler wrote:
> While trying to fix http://bugzilla.kernel.org/show_bug.cgi?id=8952
> I looked at a few other drivers to figure out what drivers _should_
> be doing for suspend/resume. I noticed typhoon driver is likely doing
> more than it needs to.  Patch below is untested since I don't have the HW.

I'm sure I copied this from another driver, but its been so long...
I won't be in a position to test it for a few days, but I agree it
shouldn't add break anything, so

Acked-by: Dave Dillow <dave@thedillows.org>

