From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: 2.6.27 problem with shaping using netem/ifb (regression?)
Date: Wed, 1 Oct 2008 18:42:02 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52064FB007@orsmsx418.amr.corp.intel.com>
References: <1222902286.6395.22.camel@tng>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Patrick McManus" <mcmanus@ducksong.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62859 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752089AbYJBBmI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 21:42:08 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1222902286.6395.22.camel@tng>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Any thoughts on where to look? I hope attaching the script is helpful
-
> it is pretty self evident when running it if things are working ok.
> This
> is all on amd64 if that is relevant.

Have you tried disabling TSO and/or GSO on the loopback device?
