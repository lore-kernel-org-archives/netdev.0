From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH] [2.4] forcedeth network driver
Date: Sun, 25 Jan 2004 10:11:24 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16402.64412.577682.141249@cargo.ozlabs.ibm.com>
References: <4012BF44.9@colorfullife.com>
	<4012D3C6.1050805@pobox.com>
	<20040124220545.GA3246@ucw.cz>
	<4012F2B7.3080800@gmx.net>
	<20040124224635.GA3448@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>,
        Jeff Garzik <jgarzik@pobox.com>,
        Manfred Spraul <manfred@colorfullife.com>,
        linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vojtech Pavlik <vojtech@suse.cz>
In-Reply-To: <20040124224635.GA3448@ucw.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vojtech Pavlik writes:

> Well, my memory may be tricking me (I'm not really sure about this), but
> I remember there was supposed to be a PPC64 northbridge with a HT link,
> made exactly for the purpose of connecting an nForce southrbridge to it.
> But it definitely is not in production yet.

The U3 northbridge in the Apple G5 powermac has a HT link coming out
of it, which connects via an AMD PCI-X tunnel chip to an Apple K2
southbridge.  I have never heard of anyone using (or planning to use)
an nForce southbridge on a PPC64 system though.

Regards,
Paul.
