From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 4/5] [E1000]: [VLAN] Turn off the HW vlan filter if promisc
Date: Fri, 18 Apr 2008 11:08:46 +0900
Message-ID: <b25c3fa70804171908h1649d279we94b1c3f52fe33b2@mail.gmail.com>
References: <20080411135851.GD8137@tp64> <4807C03E.7060705@intel.com>
	 <b25c3fa70804171854s7b056da1u89e9b758c494a07@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jeff@garzik.org, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.230]:29020 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbYDRCIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Apr 2008 22:08:48 -0400
Received: by qb-out-0506.google.com with SMTP id e11so215660qbe.15
        for <netdev@vger.kernel.org>; Thu, 17 Apr 2008 19:08:47 -0700 (PDT)
In-Reply-To: <b25c3fa70804171854s7b056da1u89e9b758c494a07@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2008/4/18, Joonwoo Park <joonwpark81@gmail.com>:
> No, the admin configured promisc flag on the netdev. It means that the
> admin would like to see all the packets on the wire not one particular
> vlan traffic I think.
> If admin would like to sniff one vlan, he or she should configure promisc.

sorry
      ^ not

Joonwoo
