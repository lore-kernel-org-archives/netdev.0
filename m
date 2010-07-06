From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH v2 1/9] atm: propagate signal changes via notifier
Date: Tue, 6 Jul 2010 15:33:14 -0400
Message-ID: <20100706153314.16d3b5c0@thirdoffive.cmf.nrl.navy.mil>
References: <1278319561-23548-1-git-send-email-karl@hiramoto.org>
	<1278319561-23548-2-git-send-email-karl@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	nathan@traverse.com.au
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:44661 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541Ab0GFTdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jul 2010 15:33:53 -0400
In-Reply-To: <1278319561-23548-2-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  5 Jul 2010 10:45:53 +0200
Karl Hiramoto <karl@hiramoto.org> wrote:


> +/**
> +* register_atmdevice_notifier - register atm_dev notify events
> +* Currently we notify of signal found/lost
> +*/

per Documentation/CodingStyle, the preferred style for multiline
comments would look like:

/*
 * This is the preferred style for multi-line
 * comments in the Linux kernel source code.
 * Please use it consistently.
 *
 * Description:  A column of asterisks on the left side,
 * with beginning and ending almost-blank lines.
 */

please update all your comments to reflect this style.
