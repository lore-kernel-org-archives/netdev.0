From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/9 Rev3] Implement batching skb API and support in
	IPoIB
Date: Fri, 24 Aug 2007 08:36:57 -0400
Message-ID: <1187959017.4255.43.camel@localhost>
References: <46CC6DD1.5020105@hp.com>
	 <20070822.132145.90824527.davem@davemloft.net>
	 <1187906650.4279.16.camel@localhost>
	 <20070823.153047.99173582.davem@davemloft.net>
	 <1187908702.4279.36.camel@localhost>
	 <20070823203425.2a32fb3f@freepuppy.rosehill.hemminger.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	krkumar2@in.ibm.com, gaagaan@gmail.com,
	general@lists.openfabrics.org, herbert@gondor.apana.org.au,
	jagana@us.ibm.com, jeff@garzik.org, johnpol@2ka.mipt.ru,
	kaber@trash.net, mcarlson@broadcom.com, mchan@broadcom.com,
	netdev@vger.kernel.org, peter.p.waskiewicz.jr@intel.com,
	rdreier@cisco.com, Robert.Olsson@data.slu.se, sri@us.ibm.com,
	tgraf@suug.ch, xma@us.ibm.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.186]:47213 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758606AbXHXMhD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 08:37:03 -0400
Received: by rv-out-0910.google.com with SMTP id k20so640905rvb
        for <netdev@vger.kernel.org>; Fri, 24 Aug 2007 05:37:03 -0700 (PDT)
In-Reply-To: <20070823203425.2a32fb3f@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-23-08 at 20:34 -0700, Stephen Hemminger wrote:

> A current hot topic of research is reducing the number of ACK's to make TCP
> work better over asymmetric links like 3G.

One other good reason to reduce ACKs to battery powered (3G) terminals
is it reduces the power consumption i.e you have longer battery life.

cheers,
jamal

