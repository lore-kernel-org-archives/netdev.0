From: James Morris <jmorris@namei.org>
Subject: Re: [RFC 1/3] secid reconciliation on inbound
Date: Wed, 2 Aug 2006 00:19:33 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608020018410.16774@d.namei>
References: <44CFD0DA.9060205@trustedcs.com> <Pine.LNX.4.64.0608011912130.14724@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:21736 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751130AbWHBETg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 00:19:36 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <Pine.LNX.4.64.0608011912130.14724@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Aug 2006, James Morris wrote:

> On Tue, 1 Aug 2006, Venkat Yekkirala wrote:
> 
> > +#define PACKET__COME_THRU                         0x00000008UL
> > +#define PACKET__GO_THRU                           0x00000010UL
> 
> These names seem awkward, and do we really need a separate perm for each 
> direction?

Ok, I see we need separate permissions.  The naming, still...


- James
-- 
James Morris
<jmorris@namei.org>
