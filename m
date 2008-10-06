From: "Zou, Yi" <yi.zou@intel.com>
Subject: RE: [PATCH 1/2] net: add ETH_P_FCOE for Fibre Channel over Ethernet (FCoE)
Date: Mon, 6 Oct 2008 16:11:00 -0700
Message-ID: <85B0945B2DB96C40BE3F762205A682ED03D4408F@orsmsx420.amr.corp.intel.com>
References: <20081006220524.3308.64889.stgit@zyfc9ini.jf.intel.com><20081006220920.3308.18862.stgit@zyfc9ini.jf.intel.com> <ada3aj9pd4u.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11071 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756276AbYJFXMv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 19:12:51 -0400
Content-class: urn:content-classes:message
In-Reply-To: <ada3aj9pd4u.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >  #define ETH_P_TIPC	0x88CA		/* TIPC
*/
> > +#define ETH_P_FCOE      0x8906          /* Fibre Channel over
Ethernet
>*/
>
>trivial -- but the patch format makes it pretty obvious -- it would
>probably be nice to use tabs to align things on the FCOE line the same
>way the other lines in the file do, rather than using spaces.

Thanks, will fix this and resubmit.

yi
