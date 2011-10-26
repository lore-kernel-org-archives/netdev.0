From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [PATCH 2/2] net/smsc911x: Add regulator support
Date: Wed, 26 Oct 2011 13:48:25 +0100
Message-ID: <20111026124824.GA29548@opensource.wolfsonmicro.com>
References: <1319616356-6391-1-git-send-email-linus.walleij@stericsson.com> <20111026083838.GA9157@opensource.wolfsonmicro.com> <4EA7D1F5.2030904@stericsson.com> <20111026101750.GA2921@opensource.wolfsonmicro.com> <4EA7E476.7030608@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Mathieu Poirer <mathieu.poirier@linaro.org>,
	Robert MARKLUND <robert.marklund@stericsson.com>,
	Linus Walleij <linus.walleij@linaro.org>
To: Linus Walleij <linus.walleij@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:46164 "EHLO
	opensource.wolfsonmicro.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932917Ab1JZMs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 08:48:26 -0400
Content-Disposition: inline
In-Reply-To: <4EA7E476.7030608@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2011 at 12:44:06PM +0200, Linus Walleij wrote:

> Aha you mean I need to go into the platform/board files
> for all systems using the smsc911x and add a fixed voltage
> regulator?

> OK that can't be too hard...

Either that or just ping all the relevant developers and let the know;
half the point of the config option is so that if something goes wrong
it's easy to get the system running.
