From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH v6 16/16] netlabel: Add configuration support for local labeling
Date: Wed, 1 Oct 2008 12:54:50 -0400
Message-ID: <200810011254.50845.paul.moore@hp.com>
References: <20080916124722.17132.38741.stgit@flek.lan> <20080916125737.17132.50669.stgit@flek.lan> <alpine.LRH.1.10.0810012011050.6732@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:40147 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753014AbYJAQyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 12:54:53 -0400
In-Reply-To: <alpine.LRH.1.10.0810012011050.6732@tundra.namei.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 01 October 2008 6:13:39 am James Morris wrote:
> On Tue, 16 Sep 2008, Paul Moore wrote:
> > Add the necessary NetLabel support for the new CIPSO mapping,
> > CIPSO_V4_MAP_LOCAL, which allows full LSM label/context support.
>
> Now, CIPSO is useful :-)

 :-P

I told you guys I'd make this compelling, I just needed a 
<cough>few</cough> years :)

-- 
paul moore
linux @ hp
