From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: RE: [PATCH 03/08] [TIPC]: Eliminate "sparse" warning in socket code
Date: Fri, 22 Feb 2008 12:10:46 -0800
Message-ID: <AF1602CB2550CE4381C0C75118A7856B0246C8A5@ala-mail02.corp.ad.wrs.com>
References: <AF1602CB2550CE4381C0C75118A7856B0246C891@ala-mail02.corp.ad.wrs.com> <20080222200425.GC7154@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Sam Ravnborg" <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40988 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935297AbYBVULu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 15:11:50 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20080222200425.GC7154@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sam:

Yes and yes.  Some fixes will occur naturally as the problematic code
has already been rewritten in TIPC 1.7, but other fixes will need to be
developed.  I'll see what I can do to accelerate the process ...

-- Al 

-----Original Message-----
From: Sam Ravnborg [mailto:sam@ravnborg.org] 
Sent: Friday, February 22, 2008 3:04 PM
To: Stephens, Allan
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH 03/08] [TIPC]: Eliminate "sparse" warning in socket
code

On Fri, Feb 22, 2008 at 11:59:12AM -0800, Stephens, Allan wrote:
> This patch eliminates warnings about a pair of undeclared symbols.

Hi Allan.

Last I looked there where ~90 sparse warnings for tipc.
I assume you are aware and that they are getting fixed.

	Sam - who would like to see an almost sparse clean kernel
