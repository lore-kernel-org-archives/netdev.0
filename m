From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Extensible hashing and RCU
Date: Thu, 22 Feb 2007 12:41:05 +0100
Message-ID: <20070222114105.GA12844@one.firstfloor.org>
References: <200702201209.52388.dada1@cosmosbay.com> <p73y7mrd6o9.fsf@bingen.suse.de> <200702211419.30856.dada1@cosmosbay.com> <20070221.053721.112287244.davem@davemloft.net> <17884.53809.880275.142372@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:34598 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945974AbXBVLlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 06:41:09 -0500
Content-Disposition: inline
In-Reply-To: <17884.53809.880275.142372@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>  With 100k flows we typically see an aver depth 1.3 and a max depth 4. Right 

This includes full srcport:dstport?

>  now there is only a dst entry in leaf nodes. So yes anything else we can put 
>  in leaf is "free".

How much would fit there?


-Andi
