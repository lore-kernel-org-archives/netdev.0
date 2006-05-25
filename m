From: Dave Dillow <dave@thedillows.org>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 09:34:22 -0400
Message-ID: <1148564063.25551.2.camel@dillow.idleaire.com>
References: <20060523.182217.59656237.davem@davemloft.net>
	 <4474AE92.3030501@garzik.org> <20060524191442.GG22881@ipom.com>
	 <200605241501.53477.bcook@bpointsys.com> <4474BD52.6020604@garzik.org>
	 <20060525032357.4990425f.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.idleaire.net ([65.220.16.2]:53167 "EHLO iasrv1.idleaire.net")
	by vger.kernel.org with ESMTP id S965182AbWEYNe2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 09:34:28 -0400
To: Bill Fink <billfink@mindspring.com>
In-Reply-To: <20060525032357.4990425f.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-05-25 at 03:23 -0400, Bill Fink wrote:
> likely problem areas.  The human mind (at least speaking for myself) is
> not nearly as adept when having to deal with deltas.  Yes, you can record
> the initial state of all the devices, run the stress test, record the new
> state of all the devices, and then spend a large amount of time devising
> a script to calculate all the deltas for all the scores of variables on
> all the involved devices, and then finally try and figure out what is
> wrong.  But it would be so much better, easier, and more efficient, if
> the kernel simply provided such a feature that almost all other networking
> devices provide.

ftp://ftp.cup.hp.com/dist/networking/tools/beforeafter.tar.gz
as Rick mentioned earlier, and then you won't need to write a
complicated script.
-- 
Dave Dillow <dave@thedillows.org>

