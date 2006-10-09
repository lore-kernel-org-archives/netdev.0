From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 00/11] The _entire_ secid reconciliation patchset (tada!)
Date: Mon, 9 Oct 2006 16:19:29 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610091612140.31187@d.namei>
References: <20061009194223.402695000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:32151 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964809AbWJIUTc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 16:19:32 -0400
To: Paul Moore <paul.moore@hp.com>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <20061009194223.402695000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Oct 2006, paul.moore@hp.com wrote:

> Please consider this for inclusion into 2.6.20.  If it's too soon to be
> thinking of 2.6.20 let me know and I'll rebase/resend this patchset once I see
> notice of David's net-2.6.20 git tree.

>From an initial review of this patchset, it doesn't look quite ready to 
queue for 2.6.20 (which I plan to to via git once it is).

Outstanding items include resolving the igmp skb hook issue generally, 
testing to verify both the design and implementation, and ensuring that 
all the related policy changes are merged upstream first.



- James
-- 
James Morris
<jmorris@namei.org>
