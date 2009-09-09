From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [IB] 2.6.31-rc9: SW2HW_EQ failed on Dell R610
Date: Wed, 09 Sep 2009 09:36:56 -0700
Message-ID: <adafxawkrbr.fsf@cisco.com>
References: <alpine.DEB.1.10.0909081805110.7733@V090114053VZO-1>
	<ada1vmgn76v.fsf@cisco.com>
	<alpine.DEB.1.10.0909091001450.28070@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:29216 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753349AbZIIQgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 12:36:53 -0400
In-Reply-To: <alpine.DEB.1.10.0909091001450.28070@V090114053VZO-1> (Christoph
	Lameter's message of "Wed, 9 Sep 2009 10:02:29 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > > The workaround of limiting possible cpus to 16 should be OK for the time
 > > between 2.6.31 and 2.6.31.1.

 > Why not merge it immediately? Dell R610s are fairly standard.

I think it's too late now post-rc9 ... it's not a regression (I think
the bug has been there since 2.6.29) and I think Linus would prefer to
minimize the # of patches that go in now.

 - R.
