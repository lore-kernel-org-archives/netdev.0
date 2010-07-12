From: Karl Beldan <karl.beldan@gmail.com>
Subject: net/dsa
Date: Mon, 12 Jul 2010 22:59:29 +0200
Message-ID: <4C3B8231.6020706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51097 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753301Ab0GLU7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jul 2010 16:59:46 -0400
Received: by wyf23 with SMTP id 23so3710560wyf.19
        for <netdev@vger.kernel.org>; Mon, 12 Jul 2010 13:59:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I found the dsa code very handy to help manage a switch.
Yet I was surprised I had to tweak the code to simply use the phy layer
state machine.
And I don't see much activity in the code nor any discussion, e.g no
follow up to http://patchwork.ozlabs.org/patch/16578.

So I was wondering if there was anybody playing with this code, or
having ideas about features to add (vlan/stp callbacks) ?



Karl
