From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/3] ethtool: Addition of -m option to dump module eeprom
Date: Wed, 23 May 2012 01:01:07 +0100
Message-ID: <1337731267.2953.4.camel@bwh-desktop.uk.solarflarecom.com>
References: <4FB663A5.3060107@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>
To: Stuart Hodgson <smhodgson@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:46077 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932839Ab2EWABL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 20:01:11 -0400
In-Reply-To: <4FB663A5.3060107@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-18 at 15:58 +0100, Stuart Hodgson wrote:
> The -m option now allows for retrieval of EEPROM
> information form a plug in module such as SFP+. This
> shows specific information about the type and
> capabilities of the module in use The format can be
> easily extended to support other modules types such as
> QSFP in future. Raw data dump is also supported.
[...]

Applied, thanks.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
