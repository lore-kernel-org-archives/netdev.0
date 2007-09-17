From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 0/10 REV5] Implement skb batching and support in
	IPoIB/E1000
Date: Sun, 16 Sep 2007 20:29:18 -0400
Message-ID: <1189988958.4230.55.camel@localhost>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	 <20070916.161748.48388692.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	herbert@gondor.apana.org.au, kaber@trash.net,
	shemminger@linux-foundation.org, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, rick.jones2@hp.com, xma@us.ibm.com,
	gaagaan@gmail.com, netdev@vger.kernel.org, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, mchan@broadcom.com, general@lists.openfabrics.org,
	kumarkr@linux.ibm.com, tgraf@suug.ch, randy.dunlap@oracle.com,
	sri@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:26487 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751347AbXIQA3X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 20:29:23 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1210634wxd
        for <netdev@vger.kernel.org>; Sun, 16 Sep 2007 17:29:22 -0700 (PDT)
In-Reply-To: <20070916.161748.48388692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-16-09 at 16:17 -0700, David Miller wrote:

> The only major complaint I have about this patch series is that
> the IPoIB part should just be one big changeset. 

Dave, you do realize that i have been investing my time working on
batching as well, right? 

cheers,
jamal


