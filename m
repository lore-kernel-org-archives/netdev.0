From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: Key change for TCP_MD5
Date: Wed, 02 Dec 2009 09:13:51 -0500
Message-ID: <4B16761F.6020709@gmail.com>
References: <911b679e0912011627q568132e8x655f109c75030725@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Xiaochun Lu <xiaoclu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:61968 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754308AbZLBONw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 09:13:52 -0500
In-Reply-To: <911b679e0912011627q568132e8x655f109c75030725@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Xiaochun Lu wrote:
> know rfc4808 is targeting to solve this issue. Does there any plan to
> implement rfc4808 for linux?
> 
There's a replacement effort at:

   http://www.ietf.org/internet-drafts/draft-ietf-tcpm-tcp-auth-opt-08.txt
   http://www.ietf.org/internet-drafts/draft-ietf-tcpm-tcp-ao-crypto-01.txt

Probably going another round with them before writing code for Linux.
