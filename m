From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 2/3] mlsxfrm: Various fixes
Date: Thu, 9 Nov 2006 02:02:14 -0500 (EST)
Message-ID: <XMMS.LNX.4.64.0611090158550.11301@d.namei>
References: <000501c70342$83b9df70$cc0a010a@tcssec.com> <4552A9AC.3060708@hp.com>
 <Pine.LNX.4.64.0611082337520.5916@d.namei> <4552B5C1.8040007@hp.com>
 <Pine.LNX.4.64.0611090109120.10907@d.namei> <4552CD3B.40809@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: vyekkirala@TrustedCS.com, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:5100 "EHLO
	mail2.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1754353AbWKIHCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 02:02:16 -0500
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <4552CD3B.40809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Nov 2006, Paul Moore wrote:

> It sounds like you have an idea of how you would like to see this implemented,
> can you give me a rough outline?  Is this the partitioned SECMARK field you
> talked about earlier?

No, just the fact that you are in the same kernel address space and can 
readily access the security context of the peer.



- James
-- 
James Morris
<jmorris@namei.org>
