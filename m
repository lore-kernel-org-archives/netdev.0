From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Networking: Core: netpoll: Fixed a missing spin_unlock
Date: Mon, 1 Aug 2016 00:09:10 +0200
Message-ID: <20160731220910.GA30064@electric-eye.fr.zoreil.com>
References: <1469840027-17057-1-git-send-email-salilkapur93@gmail.com>
 <20160730215836.GA22500@electric-eye.fr.zoreil.com>
 <CAJksCdT5DkbrQ_OAigJim_qT3WXo6sPv07KrBcAtTsHFLMzO4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Salil Kapur <salilkapur93@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50922 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbcGaWL3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 18:11:29 -0400
Content-Disposition: inline
In-Reply-To: <CAJksCdT5DkbrQ_OAigJim_qT3WXo6sPv07KrBcAtTsHFLMzO4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Salil Kapur <salilkapur93@gmail.com> :
> I was looking at v3.12. Can we submit patches for stable versions?

It has already been fixed in 3.12.8 as 56399d8b44beae5b80e1eda0350ab6af72baf4d0
("netpoll: Fix missing TXQ unlock and and OOPS.") by davem.

3.12.8 dates back to 2014/01. The current 3.12.x version is 3.12.62.

-- 
Ueimor
