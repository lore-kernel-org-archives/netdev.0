From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 11:49:14 +0300
Message-ID: <200808281149.14502.denys@visp.net.lb>
References: <200808220457.40892.denys@visp.net.lb> <20080827203518.7f6075a0@extreme>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:37800 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbYH1Ium (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 04:50:42 -0400
In-Reply-To: <20080827203518.7f6075a0@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 August 2008, Stephen Hemminger wrote:
>
> What kernel version is this?  There was a fix to AF_PACKET about a year ago
> to reduce this.
> --
git net-2.6 based on 2.6.27-rc3. Means very fresh.

