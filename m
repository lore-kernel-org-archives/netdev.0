From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH] f_phonet: avoid pskb_pull(), fix OOPS with
 CONFIG_HIGHMEM
Date: Mon, 21 Feb 2011 16:50:54 +0200
Message-ID: <20110221145054.GI23087@legolas.emea.dhcp.ti.com>
References: <1298297813-4795-1-git-send-email-remi.denis-courmont@nokia.com>
Reply-To: balbi@ti.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: =?iso-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog101.obsmtp.com ([74.125.149.67]:37487 "EHLO
	na3sys009aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750943Ab1BUOu7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 09:50:59 -0500
Content-Disposition: inline
In-Reply-To: <1298297813-4795-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 21, 2011 at 04:16:53PM +0200, R=E9mi Denis-Courmont wrote:
> This is similar to what we arleady do in cdc-phonet.c in the same
			      ^^typo

--=20
balbi
