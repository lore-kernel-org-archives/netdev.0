From: James Morris <jmorris@namei.org>
Subject: Re: when having to acquire an SA, ipsec drops the packet
Date: Mon, 5 Feb 2007 11:33:46 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0702051133050.32533@d.namei>
References: <1170370281.2603.359.camel@faith.austin.ibm.com>
 <Pine.LNX.4.64.0702011819070.11820@d.namei> <20070204.205315.10325007.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: latten@austin.ibm.com, netdev@vger.kernel.org, paul.moore@hp.com,
	vyekkirala@TrustedCS.com, herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:59493 "EHLO
	mail4.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682AbXBEQdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 11:33:50 -0500
In-Reply-To: <20070204.205315.10325007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 4 Feb 2007, David Miller wrote:

> Something like this (untested) on the ipv4 side, for example:

Looks like it should work.  Will do some testing.


-- 
James Morris
<jmorris@namei.org>
