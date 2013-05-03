From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v7 4/6] vxlan: add ipv6 support
Date: Fri, 03 May 2013 11:02:11 +0800
Message-ID: <1367550131.2415.48.camel@cr0>
References: <1367311395-15891-1-git-send-email-amwang@redhat.com>
	 <1367311395-15891-5-git-send-email-amwang@redhat.com>
	 <87r4hscr7s.fsf@nemi.mork.no> <1367313956.3216.18.camel@cr0>
	 <87mwsgcnoy.fsf@nemi.mork.no> <1367481953.2415.29.camel@cr0>
	 <87sj25a6tr.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Stevens <dlstevens@us.ibm.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27290 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757783Ab3ECDC2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 May 2013 23:02:28 -0400
In-Reply-To: <87sj25a6tr.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-05-02 at 14:45 +0200, Bj=C3=B8rn Mork wrote:
> Yes, I am pretty sure of that as well.  That's why I ask you to *test=
*
> your code with assorted settings before resubmitting it.  I'm not
> going
> to.=20

I have two scripts to test my patch, one for IPv4 and one for IPv6. Bot=
h
use the default configuration on Fedora.

That is chicken-and-egg problem, if I wasn't aware of such sysctl's, ho=
w
possible could I test it with different settings? Please don't doubt I
have tested it as much as I can, I just didn't know some IPv6 specific
sysctl's exist.
