From: Jeremy Jackson <jerj@coplanar.net>
Subject: Re: autotuning of send buffer size of a socket
Date: Wed, 14 May 2008 14:26:17 -0400
Message-ID: <1210789577.6956.9.camel@ragnarok>
References: <4a4634330805121200m739e67bdife66c3ad81af1ceb@mail.gmail.com>
	 <1210639647.2753.10.camel@w-sridhar2.beaverton.ibm.com>
	 <4a4634330805130654n1aafbf10pa73da07e792f7b@mail.gmail.com>
	 <1210722503.11436.9.camel@w-sridhar2.beaverton.ibm.com>
	 <4a4634330805140722x3494626bpc78dd92831d384a@mail.gmail.com>
	 <4a4634330805141111s585fd928n824e20fc83a74819@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Shirish Pargaonkar <shirishpargaonkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from titan.coplanar.net ([70.47.139.2]:58392 "EHLO
	titan.coplanar.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755090AbYENS0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 14:26:40 -0400
In-Reply-To: <4a4634330805141111s585fd928n824e20fc83a74819@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry if this has been covered already, but doesn't Samba set the write
buffer size, thereby disabling autotuning?

-- 
Jeremy Jackson
Coplanar Networks
(519)489-4903
http://www.coplanar.net
jerj@coplanar.net

