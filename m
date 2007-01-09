From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH 1/10] cxgb3 - main header files
Date: Tue, 09 Jan 2007 09:09:21 -0800
Message-ID: <ada4pr0ceke.fsf@cisco.com>
References: <20061220124125.6286.17148.stgit@localhost.localdomain>
	<45918CA4.3020601@garzik.org> <45A36C22.6010009@chelsio.com>
	<45A36E59.30500@garzik.org> <adamz4scgfo.fsf@cisco.com>
	<45A3C5D5.6030105@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:37444 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932247AbXAIRJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 12:09:47 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45A3C5D5.6030105@garzik.org> (Jeff Garzik's message of "Tue, 09 Jan 2007 11:41:57 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > The time for adding new stuff to 2.6.20 is /long/ past.  We stop
 > adding things like new drivers when Linus releases 2.6.X-rc1.

Well, in the past I think new drivers have been added after the merge
window, given that there's no chance of regressions (old kernel == no
support for device X, so even if the new driver is buggy it's no worse
than the old kernel).  (eg a quick git scan shows commit 0f64478c
added a USB driver between 2.6.19-rc2 and 2.6.19-rc3, and I'm sure you
can find lots of other examples)

Anyway, you answered my question.  I wasn't pushing to include the
driver now, I just wanted to know what you were planning to do.

Thanks.

 - R.
