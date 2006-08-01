From: James Morris <jmorris@namei.org>
Subject: Re: [RFC 1/3] secid reconciliation on inbound
Date: Tue, 1 Aug 2006 19:19:34 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608011912130.14724@d.namei>
References: <44CFD0DA.9060205@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail8.sea5.speakeasy.net ([69.17.117.10]:1225 "EHLO
	mail8.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750735AbWHAXTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 19:19:38 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <44CFD0DA.9060205@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Aug 2006, Venkat Yekkirala wrote:

> +#define PACKET__COME_THRU                         0x00000008UL
> +#define PACKET__GO_THRU                           0x00000010UL

These names seem awkward, and do we really need a separate perm for each 
direction?



- James
-- 
James Morris
<jmorris@namei.org>
