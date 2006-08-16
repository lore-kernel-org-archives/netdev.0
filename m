From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [RFC] network namespaces
Date: Wed, 16 Aug 2006 19:12:26 +0400
Message-ID: <20060816151226.GA11687@ms2.inr.ac.ru>
References: <20060815182029.A1685@castle.nmd.msu.ru> <20060816115313.GC31810@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Savochkin <saw@sw.ru>, netdev@vger.kernel.org,
	dlezcano@fr.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	herbert@13thfloor.at, sam@vilain.net, ebiederm@xmission.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, devel@openvz.org,
	alexey@sw.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:15790 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932067AbWHPPTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 11:19:48 -0400
To: "Serge E. Hallyn" <serue@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20060816115313.GC31810@sergelap.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> (application) containers.  Performance aside, are there any reasons why
> this approach would be problematic for c/r?

This approach is just perfect for c/r.

Probably, this is the only approach when migration can be done
in a clean and self-consistent way.

Alexey
