From: "Venkat Yekkirala" <vyekkirala@trustedcs.com>
Subject: RE: [PATCH 00/11] The _entire_ secid reconciliation patchset (tada!)
Date: Wed, 11 Oct 2006 14:20:07 -0500
Message-ID: <001101c6ed6a$43ae71e0$cc0a010a@tcssec.com>
References: <Pine.LNX.4.64.0610091612140.31187@d.namei>
Reply-To: <vyekkirala@trustedcs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <selinux@tycho.nsa.gov>,
	"Venkat Yekkirala" <vyekkirala@tcsfw4.tcs-sec.com>,
	"Stephen Smalley" <sds@tycho.nsa.gov>,
	"Eric Paris" <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:34609 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161354AbWJKTUz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Oct 2006 15:20:55 -0400
To: "'James Morris'" <jmorris@namei.org>,
	"Paul Moore" <paul.moore@hp.com>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610091612140.31187@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From an initial review of this patchset, it doesn't look 
> quite ready to 
> queue for 2.6.20 (which I plan to to via git once it is).
> 
> Outstanding items include resolving the igmp skb hook issue 
> generally, 
> testing to verify both the design and implementation, and 
> ensuring that 
> all the related policy changes are merged upstream first.
> 
Regarding the igmp hook issue, we could do a generic hook
like Paul suggested. Would that be more palatable you think?
