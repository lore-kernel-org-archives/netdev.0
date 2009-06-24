From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: bnx2 firmware problem with 2.6.30
Date: Wed, 24 Jun 2009 12:18:52 +0200
Message-ID: <BAY103-DAV98BB612E3FD17243F9D83B2370@phx.gbl>
References: <BAY103-DAV109D9C8B5604B2AF4A84EB2360@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s12.bay0.hotmail.com ([65.54.246.212]:20638 "EHLO
	bay0-omc3-s12.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751241AbZFXKUY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2009 06:20:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this fix the problem:

CONFIG_FIRMWARE_IN_KERNEL=y
CONFIG_BNX2=y

