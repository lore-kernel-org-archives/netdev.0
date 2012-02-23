From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: Re: WARNING: at kernel/softirq.c:159
 _local_bh_enable_ip+0x35/0x71()
Date: Thu, 23 Feb 2012 16:30:55 +0100
Message-ID: <1330011055.11248.21.camel@twins>
References: <1422860.157191329872584374.JavaMail.weblogic@epml01>
	 <20120223104237.GA2127@electric-eye.fr.zoreil.com>
	 <1329998028.15610.14.camel@edumazet-laptop>
	 <1330003354.11248.9.camel@twins>
	 <1330006866.15610.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Jongman Heo <jongman.heo@samsung.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Scott J. Goldman" <scottjg@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:39919 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753728Ab2BWPbD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 10:31:03 -0500
In-Reply-To: <1330006866.15610.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-23 at 15:21 +0100, Eric Dumazet wrote:
> Well, definitely a cleanup is possible, but probably not suitable for
> 3.3 and stable kernels ? 

Nah, that'd be better suited for a development branch like :-)
