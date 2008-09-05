From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v4 12/14] netlabel: Changes to the NetLabel security
 attributes to allow LSMs to pass full contexts
Date: Fri, 5 Sep 2008 19:12:47 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0809051912350.2526@tundra.namei.org>
References: <20080903003647.15669.45349.stgit@flek.lan> <20080903005013.15669.42041.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:58256 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035AbYIEJMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 05:12:50 -0400
In-Reply-To: <20080903005013.15669.42041.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2 Sep 2008, Paul Moore wrote:

> This patch provides support for including the LSM's secid in addition to
> the LSM's MLS information in the NetLabel security attributes structure.
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>
> ---
> 
>  include/net/netlabel.h         |    2 +-
>  security/selinux/ss/services.c |    3 ++-
>  2 files changed, 3 insertions(+), 2 deletions(-)

Acked-by: James Morris <jmorris@namei.org>


-- 
James Morris
<jmorris@namei.org>
