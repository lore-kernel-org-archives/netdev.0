From: "Nikolaos D. Bougalis" <nikb@webmaster.com>
Subject: Re: XOR hash beauty solved [Was: RFC: Established connections hash function]
Date: Fri, 23 Mar 2007 05:51:27 -0700
Message-ID: <7DA94C1A76514C139BA41D202A7DEDFC@XEON>
References: <391F64D0A7C5463CA2D70362E4B3E7EC@XEON> <20070322182156.GB17793@2ka.mipt.ru> <1199CE22A40740D28833A585014BE559@XEON> <20070322.135834.74723088.davem@davemloft.net> <20070323080715.GB29991@2ka.mipt.ru> <20070323115805.GA23480@2ka.mipt.ru>
Reply-To: nikb@webmaster.com
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="koi8-r";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.webmaster.com ([216.152.64.169]:1604 "EHLO
	mail1.webmaster.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422847AbXCWMvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 08:51:36 -0400
Received: from XEON by webmaster.com
	(Cipher TLSv1:RC4-MD5:128) (MDaemon.PRO.v8.1.3.R)
	with ESMTP id md50001458263.msg
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 05:51:44 -0800
In-Reply-To: <20070323115805.GA23480@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So, briefly saying, jhash_2/3words have safe distribution, but have
> higher-number of elements waves as a result of folding which is
> unavoidable for general-purpose hash.

    Thanks for the analysis. 

    -n


