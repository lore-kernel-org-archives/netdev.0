From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v2 0/2] Labeled networking patches for 2.6.26
Date: Thu, 10 Apr 2008 17:25:59 -0400
Message-ID: <200804101725.59604.paul.moore@hp.com>
References: <20080409204936.26774.55254.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:18778 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756875AbYDJV0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 17:26:02 -0400
In-Reply-To: <20080409204936.26774.55254.stgit@flek.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just a quick follow-up on testing, I've run this for a few hours on two 
Fedora systems with both labeled and unlabeled IPsec in use with SAs 
rekeying every 5 minutes and didn't notice anything evil.

At this point I'd strip the "RFC" from the patchset and ask that they be 
considered for inclusion in 2.6.26 assuming there are no objections.

-- 
paul moore
linux @ hp
