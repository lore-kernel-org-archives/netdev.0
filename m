From: James Morris <jmorris@namei.org>
Subject: Re: [RFC PATCH v6 16/16] netlabel: Add configuration support for
 local labeling
Date: Wed, 1 Oct 2008 20:13:39 +1000 (EST)
Message-ID: <alpine.LRH.1.10.0810012011050.6732@tundra.namei.org>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125737.17132.50669.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:60565 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753573AbYJAKNl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Oct 2008 06:13:41 -0400
In-Reply-To: <20080916125737.17132.50669.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Sep 2008, Paul Moore wrote:

> Add the necessary NetLabel support for the new CIPSO mapping,
> CIPSO_V4_MAP_LOCAL, which allows full LSM label/context support.

Now, CIPSO is useful :-)


Reviewed-by: James Morris <jmorris@namei.org>



-- 
James Morris
<jmorris@namei.org>
