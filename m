From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] Fix velocity driver unmapping incorrect size.
Date: Mon, 22 Jun 2009 01:15:43 -0400
Message-ID: <20090622051543.GA26942@redhat.com>
References: <20090621173745.GC26093@redhat.com> <20090621.184345.194558005.davem@davemloft.net> <20090622033735.GA9923@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:56676 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751412AbZFVFPn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2009 01:15:43 -0400
Content-Disposition: inline
In-Reply-To: <20090622033735.GA9923@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 21, 2009 at 11:37:35PM -0400, Dave Jones wrote:
 > Oh man, this was subtle.  How did this never bite us before ?
 
bah. I introduced that back in 59f8e169e25c5fce91826412c38359ecaf940b82

I suck at ternary operators.

	Dave

