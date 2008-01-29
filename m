From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipcomp regression in 2.6.24
Date: Tue, 29 Jan 2008 09:07:52 +0100
Message-ID: <BAY103-DAV76D55A34FB3E0924FF49AB2350@phx.gbl>
References: <3C59DB883F7B0B4D8096010D45ACCD134F2086@exch.facton.local>
Cc: <netdev@vger.kernel.org>
To: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s34.bay0.hotmail.com ([65.54.246.106]:54617 "EHLO
	bay0-omc1-s34.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750778AbYA2IIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 03:08:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Beschorner Daniel wrote:

> Has someone an idea which patch could have damaged ipcomp?
>
> Daniel
>
> > With 2.6.24 IPSEC/ESP tunnels to older kernels establish fine, data
> > flows in both directions, but no data comes out of the tunnel.
> > Needed to disable ipcomp.

Same problem here: linux 2.6.24 driven by openswan 2.4.11
on Slackware 11.0



