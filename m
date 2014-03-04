From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv3 0/4] Add DT support for fixed PHYs
Date: Tue, 04 Mar 2014 21:09:53 +0300
Message-ID: <531616F1.5060703@cogentembedded.com>
References: <1393930704-24374-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian@openwrt.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:58884 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755290AbaCDRJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 12:09:53 -0500
Received: by mail-la0-f50.google.com with SMTP id y1so5906043lam.9
        for <netdev@vger.kernel.org>; Tue, 04 Mar 2014 09:09:52 -0800 (PST)
In-Reply-To: <1393930704-24374-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/04/2014 01:58 PM, Thomas Petazzoni wrote:

> Here is a third version of the patch set that adds a Device Tree
> binding and the related code to support fixed PHYs.

> Since the second version, the changes have been:

>   * Rebased on top of v3.14-rc1, and re-tested on hardware.

    This needs to be rebased atop of net-next.git repo on git.kernel.org.

WBR, Sergei
