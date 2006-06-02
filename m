From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: new driver for IBM ethernet chip
Date: Fri, 2 Jun 2006 09:00:34 -0700
Message-ID: <20060602090034.8f9bf036.rdunlap@xenotime.net>
References: <OFA75C1070.77D8B8F0-ONC125717F.003D730C-C1257181.003C592B@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, MEDER@de.ibm.com, THEMANN@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:28883 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S932478AbWFBP5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2006 11:57:52 -0400
Received: from midway.site ([71.245.102.105]) by xenotime.net for <netdev@vger.kernel.org>; Fri, 2 Jun 2006 08:57:50 -0700
To: Christoph Raisch <RAISCH@de.ibm.com>
In-Reply-To: <OFA75C1070.77D8B8F0-ONC125717F.003D730C-C1257181.003C592B@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Jun 2006 13:02:37 +0200 Christoph Raisch wrote:

> We're currently developing a new Ethernet device driver for a 10G IBM chip
> for System p. (ppc64)
> 
> A later version of the driver should end up in mainline kernel.
> How should we proceed to get first comments by the community?
> Either post this code as a patch to netdev or
yes

> put a full tarball on for example sourceforge?
nope.

Please read and observe:  Documentation/SubmittingPatches
and Section 3 of it, References, for other sources of
expectations/requirements.

The -mm tree also contains Documentation/SubmitChecklist
that you may find useful.

---
~Randy
