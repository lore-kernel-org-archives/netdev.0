From: Patrick McHardy <kaber@trash.net>
Subject: Re: iproute2-2.6.20-070313 bug ?
Date: Thu, 22 Mar 2007 18:14:18 +0100
Message-ID: <4602B96A.5000308@trash.net>
References: <20070321175951.M73913@visp.net.lb>	<46026717.9060909@trash.net>	<20070322124533.M79867@visp.net.lb>	<46027FF2.6020001@trash.net> <20070322101224.3e6bb899@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40732 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934140AbXCVROU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2007 13:14:20 -0400
In-Reply-To: <20070322101224.3e6bb899@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> tc should check for overflows and doesn't. Do you want to make a patch
> for the obvious cases?


I agree. I'll take care of it once I'm done with my patches for 2.6.22.
