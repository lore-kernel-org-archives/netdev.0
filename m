From: Andi Kleen <ak@suse.de>
Subject: Re: RDMA will be reverted
Date: Tue, 25 Jul 2006 03:42:38 +0200
Message-ID: <200607250342.38984.ak@suse.de>
References: <adasllh9kj0.fsf@cisco.com> <200607250202.02913.ak@suse.de> <44C565D1.6070202@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rdreier@cisco.com,
	tom@opengridcomputing.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:10218 "EHLO mx1.suse.de")
	by vger.kernel.org with ESMTP id S932383AbWGYBnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2006 21:43:19 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <44C565D1.6070202@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 July 2006 02:29, Rick Jones wrote:
> This all sounds like the discussions we had within HP-UX between 10.20 and 11.0 
> concerning Inbound Packet Scheduling vs Thread Optimized Packet Scheduling.  

We've also talking about this for many years, just no code so far.
Or rather Linux so far left the job to manual tuning.

-Andi
