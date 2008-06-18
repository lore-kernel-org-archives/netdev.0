From: Patrick McHardy <kaber@trash.net>
Subject: Re: Traffic Control - Burst 4096Mb ?!
Date: Wed, 18 Jun 2008 12:32:27 +0200
Message-ID: <4858E43B.2080008@trash.net>
References: <BD53B6560CD66B4AA230BBB09CD2C8F3244275@ags-exch.ags-intranet.net> <BD53B6560CD66B4AA230BBB09CD2C8F346DB91@ags-exch.ags-intranet.net> <4858E2CE.5020605@trash.net> <BD53B6560CD66B4AA230BBB09CD2C8F346DB94@ags-exch.ags-intranet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean-Philippe RAMES <jprames@ags-backup.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59355 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015AbYFRKc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 06:32:28 -0400
In-Reply-To: <BD53B6560CD66B4AA230BBB09CD2C8F346DB94@ags-exch.ags-intranet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jean-Philippe RAMES wrote:
> iproute2-ss070313

That version is known to have integer overflows. Any more
revent version should fix it.
